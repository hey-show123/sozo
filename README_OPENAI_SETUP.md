# OpenAI API Setup Guide

This guide explains how to set up OpenAI API for text-to-speech (TTS) functionality in the SOZO app.

## Prerequisites

1. OpenAI account with API access
2. API key with TTS permissions

## Setup Steps

### 1. Get your OpenAI API Key

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign in to your account
3. Navigate to API Keys section
4. Create a new API key or use an existing one

### 2. Configure the .env file

Create a `.env` file in the `sozo_app` directory with the following content:

```env
# Supabase Configuration
SUPABASE_URL=https://uwgxkekvpchqzvnylszl.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3Z3hrZWt2cGNocXp2bnlsc3psIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4NDkyNzMsImV4cCI6MjA2NjQyNTI3M30.vjf738gcyGxL6iwq2oc0gREtEFlgnRylaxnuY-7FRH4

# Azure Speech Services (for pronunciation assessment)
AZURE_SPEECH_KEY=4f5c86fa8c1b4f1cbbddf8ba1e7b89a0
AZURE_SPEECH_REGION=japaneast

# OpenAI API (for text-to-speech)
OPENAI_API_KEY=your_openai_api_key_here
```

Replace `your_openai_api_key_here` with your actual OpenAI API key.

### 3. Available Voices

The app uses OpenAI's GPT-4o-mini-tts model with the following voices:

- **nova**: Used for Customer (お客さん) dialogues - bright and friendly voice
- **fable**: Used for Staff (スタッフ) dialogues and key phrases - warm and professional voice

The text is automatically adjusted for more emotional expression:
- Questions maintain their curious tone
- Greetings and suggestions are made more enthusiastic
- General statements are given more energy

Other available voices:
- alloy
- echo
- onyx
- shimmer

### 4. Testing

1. Run the app
2. Navigate to a lesson with dialogues
3. Press the play button to hear the generated speech

## Troubleshooting

### "Failed to create audio file" error

This usually means:
1. Invalid OpenAI API key
2. API key doesn't have TTS permissions
3. Network connectivity issues

### Audio not playing

Check:
1. Volume is not muted
2. Device audio permissions are granted
3. Supabase storage policies are correctly configured

### Still hearing old TTS model

If you're still hearing TTS-1 instead of gpt-4o-mini-tts:
1. The app automatically clears local cache on startup in debug mode
2. Restart the app completely (kill and restart)
3. Check console logs for "Audio cache cleared - gpt-4o-mini-tts will be used"
4. New audio files will have "_gpt4omini" in the filename

## Cost Considerations

OpenAI TTS pricing (as of 2024):
- GPT-4o-mini-tts: Typically more cost-effective than TTS-1-HD
- TTS-1-HD: $0.030 per 1 million characters

The app caches generated audio to minimize API calls and costs. Once generated, audio files are stored in Supabase and reused for subsequent playbacks. 