import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
    // 1. Handle CORS (Important for mobile app access)
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        // 2. Check for Authorization header from the app
        const authHeader = req.headers.get('Authorization')
        if (!authHeader) {
            throw new Error('Missing Authorization header')
        }

        // 3. Verify the user requesting deletion
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_ANON_KEY') ?? '',
            { global: { headers: { Authorization: authHeader } } }
        )

        const {
            data: { user },
            error: userError,
        } = await supabaseClient.auth.getUser()

        if (userError || !user) {
            console.error('User Auth Error:', userError)
            throw new Error('Unauthorized: Invalid Token')
        }

        // 4. Create Admin Client (Service Role) - THE POWERFUL KEY
        // This key allows us to bypass RLS and delete data
        const supabaseAdmin = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
            {
                auth: {
                    autoRefreshToken: false,
                    persistSession: false,
                },
            }
        )

        const userId = user.id
        console.log(`Request to delete user: ${userId}`)

        // 5. FIRST: Delete from public 'users' table (Fixes the FK error)
        // If we don't do this, the next step fails because data is linked to this user
        const { error: publicDeleteError } = await supabaseAdmin
            .from('users')
            .delete()
            .eq('id', userId)
        
        if (publicDeleteError) {
            console.error('Error deleting public profile:', publicDeleteError)
            // We log it but continue, hoping to delete the account anyway
        } else {
            console.log('Public profile deleted successfully')
        }

        // 6. SECOND: Delete the actual Account from Authentication
        const { error: deleteError } = await supabaseAdmin.auth.admin.deleteUser(
            userId
        )

        if (deleteError) {
            console.error('Error deleting user:', deleteError)
            throw deleteError
        }

        return new Response(
            JSON.stringify({ message: 'User account deleted successfully' }),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 200,
            }
        )
    } catch (error) {
        console.error('Error processing request:', error)
        return new Response(
            JSON.stringify({ error: error.message }),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 400,
            }
        )
    }
})