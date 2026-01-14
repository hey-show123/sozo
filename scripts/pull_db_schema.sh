#!/bin/bash

# Configuration
PROJECT_ID="uwgxkekvpchqzvnylszl"

# Check if supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "Error: Supabase CLI is not installed."
    echo "Please install it using: brew install supabase/tap/supabase"
    exit 1
fi

# Link project if not already linked (this might require login)
# We assume the user is logged in or will be prompted.
# Ideally, we should check if linked, but `supabase link` is safe to run.
echo "Linking Supabase project..."
supabase link --project-ref "$PROJECT_ID"

# Pull schema
echo "Pulling latest database schema..."
supabase db pull

echo "Schema pull complete! Check supabase/migrations for changes."
