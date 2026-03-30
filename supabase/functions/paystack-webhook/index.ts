
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.0.0'
import crypto from 'https://deno.land/std@0.168.0/node/crypto.ts';

const PAYSTACK_SECRET = Deno.env.get('PAYSTACK_SECRET_KEY')

serve(async (req) => {
  const signature = req.headers.get('x-paystack-signature')
  const body = await req.text()

  // Verify PayStack signature
  const hash = crypto.createHmac('sha512', PAYSTACK_SECRET).update(body).digest('hex')

  if (hash !== signature) {
    console.error('Invalid PayStack webhook signature')
    return new Response('Invalid signature', { status: 401 })
  }

  const event = JSON.parse(body)
  console.log('PayStack webhook event:', event.event)

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // Handle charge success events
    if (event.event === 'charge.success') {
      const reference = event.data.reference
      const metadata = event.data.metadata || {}
      const type = metadata.type
      const amount = event.data.amount / 100 // Convert from kobo to GHS

      console.log('Processing payment:', { reference, type, amount })

      // Check for duplicate processing using reference as idempotency key
      const { data: existingPayment } = await supabase
        .from('subscription_payments')
        .select('id')
        .eq('payment_reference', reference)
        .maybeSingle()

      if (existingPayment) {
        console.log('Payment already processed:', reference)
        return new Response(JSON.stringify({ received: true, message: 'Already processed' }), { status: 200 })
      }

      // Route based on payment type
      switch (type) {
        case 'subscription':
          await handleSubscriptionPayment(supabase, event.data, metadata)
          break

        case 'event_booking':
          await handleEventBooking(supabase, event.data, metadata)
          break

        case 'restaurant_booking':
          await handleRestaurantBooking(supabase, event.data, metadata)
          break

        case 'club_booking':
          await handleClubBooking(supabase, event.data, metadata)
          break

        default:
          console.log('Unknown payment type:', type)
          // Still update profile to premium for backwards compatibility
          const email = event.data.customer.email
          const { data: { user } } = await supabase.auth.admin.getUserByEmail(email)
          if (user) {
            await supabase.from('profiles').update({ is_premium: true }).eq('id', user.id)
          }
      }
    } else if (event.event === 'subscription.disable') {
      // Handle subscription cancellation
      const email = event.data.customer.email
      const { data: { user } } = await supabase.auth.admin.getUserByEmail(email)

      if (user) {
        await supabase.from('profiles').update({ is_premium: false }).eq('id', user.id)
        await supabase.functions.invoke('send-email', {
          body: {
            to: email,
            subject: 'Your A-Play Subscription Has Been Cancelled',
            html: '<h1>Subscription Cancelled</h1><p>Your subscription has been cancelled.</p>',
          },
        })
      }
    }

    return new Response(JSON.stringify({ received: true }), { status: 200 })
  } catch (error) {
    console.error('Webhook error:', error)
    return new Response(`Webhook Error: ${error.message}`, { status: 400 })
  }
})

// Handle subscription payment
async function handleSubscriptionPayment(supabase: any, data: any, metadata: any) {
  const email = data.customer.email
  const { data: { user } } = await supabase.auth.admin.getUserByEmail(email)

  if (!user) {
    throw new Error('User not found')
  }

  const userId = metadata.user_id || user.id
  const planId = metadata.plan_id
  const billingCycle = metadata.billing_cycle || 'monthly'

  // Create subscription
  const subscriptionData = {
    user_id: userId,
    plan_id: planId,
    status: 'active',
    billing_cycle: billingCycle,
    payment_method: 'paystack',
    payment_reference: data.reference,
    amount_paid: data.amount / 100,
    currency: data.currency,
    start_date: new Date().toISOString(),
    auto_renew: true,
  }

  await supabase.from('user_subscriptions').insert(subscriptionData)

  // Record payment
  await supabase.from('subscription_payments').insert({
    user_id: userId,
    subscription_id: planId,
    amount: data.amount / 100,
    currency: data.currency,
    payment_reference: data.reference,
    payment_method: 'paystack',
    payment_status: 'paid',
  })

  // Update profile
  await supabase.from('profiles').update({ is_premium: true }).eq('id', userId)

  console.log('Subscription created for user:', userId)
}

// Handle event booking payment
async function handleEventBooking(supabase: any, data: any, metadata: any) {
  const userId = metadata.user_id
  const eventId = metadata.event_id
  const zoneId = metadata.zone_id
  const quantity = parseInt(metadata.quantity) || 1

  // Create booking
  const bookingData = {
    user_id: userId,
    event_id: eventId,
    zone_id: zoneId,
    quantity: quantity,
    amount: data.amount / 100,
    status: 'confirmed',
    transaction_id: data.id,
    payment_status: 'paid',
    payment_method: 'paystack',
    payment_reference: data.reference,
    booking_date: new Date().toISOString(),
  }

  await supabase.from('bookings').insert(bookingData)

  console.log('Event booking created:', { userId, eventId, quantity })
}

// Handle restaurant booking payment
async function handleRestaurantBooking(supabase: any, data: any, metadata: any) {
  const userId = metadata.user_id
  const restaurantId = metadata.restaurant_id
  const tableId = metadata.table_id
  const bookingDate = metadata.booking_date
  const startTime = metadata.start_time
  const endTime = metadata.end_time
  const partySize = parseInt(metadata.party_size) || 2

  // Create restaurant booking
  const bookingData = {
    user_id: userId,
    restaurant_id: restaurantId,
    table_id: tableId,
    booking_date: bookingDate,
    start_time: startTime,
    end_time: endTime,
    party_size: partySize,
    special_requests: metadata.special_requests,
    contact_phone: metadata.contact_phone,
    status: 'confirmed',
    transaction_id: data.id,
    payment_status: 'paid',
    payment_method: 'paystack',
    payment_reference: data.reference,
    amount_paid: data.amount / 100,
    currency: data.currency,
  }

  await supabase.from('restaurant_bookings').insert(bookingData)

  console.log('Restaurant booking created:', { userId, restaurantId, tableId })
}

// Handle club booking payment
async function handleClubBooking(supabase: any, data: any, metadata: any) {
  const userId = metadata.user_id
  const clubId = metadata.club_id
  const tableId = metadata.table_id
  const bookingDate = metadata.booking_date
  const startTime = metadata.start_time
  const endTime = metadata.end_time

  // Create club booking
  const bookingData = {
    user_id: userId,
    club_id: clubId,
    table_id: tableId,
    booking_date: bookingDate,
    start_time: startTime,
    end_time: endTime,
    total_price: data.amount / 100,
    status: 'confirmed',
    transaction_id: data.id,
    payment_status: 'paid',
    payment_method: 'paystack',
    payment_reference: data.reference,
  }

  await supabase.from('club_bookings').insert(bookingData)

  console.log('Club booking created:', { userId, clubId, tableId })
}
