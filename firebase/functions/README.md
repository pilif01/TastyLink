# TastyLink Firebase Functions

This directory contains the Firebase Functions for the TastyLink app, including the main `transcribeFromLink` callable function.

## Overview

The `transcribeFromLink` function processes video/audio links and extracts recipe information using:
- **yt-dlp**: Downloads best audio-only stream
- **ffmpeg**: Converts to 16kHz mono WAV format
- **faster-whisper**: Transcribes audio with language detection
- **Rule-based extraction**: Extracts ingredients and cooking steps

## Prerequisites

- Node.js 18+
- Python 3.11+
- Firebase CLI
- Docker (for containerized deployment)

## Local Development

1. Install dependencies:
```bash
npm install
```

2. Install Python dependencies:
```bash
pip install -r requirements.txt
```

3. Start the Firebase emulator:
```bash
npm run serve
```

## Deployment

### Option 1: Standard Firebase Functions (Recommended for development)

```bash
# Build and deploy
npm run build
firebase deploy --only functions
```

### Option 2: Containerized Deployment (Recommended for production)

1. Build the Docker image:
```bash
docker build -t tasty-link-functions .
```

2. Deploy to Cloud Run:
```bash
gcloud run deploy tasty-link-functions \
  --image tasty-link-functions \
  --region europe-central2 \
  --memory 2Gi \
  --cpu 2 \
  --timeout 900 \
  --max-instances 10 \
  --allow-unauthenticated
```

## Function Details

### transcribeFromLink

**Input:**
```typescript
{
  sourceLink: string;      // Video/audio URL
  preferLang?: string;     // Preferred language code (optional)
}
```

**Output:**
```typescript
{
  recipeId: string;        // SHA256 hash of sourceLink
  title?: string;          // Extracted recipe title
  creatorHandle?: string;  // Creator identifier
  sourceLink: string;      // Original source link
  lang: string;            // Detected language
  text: {
    original: string;      // Cleaned transcript
    ro?: string;          // Romanian translation (if applicable)
  };
  ingredients: Array<{
    name: string;
    qty?: number;
    unit?: string;
    category?: string;
    notes?: string;
  }>;
  steps: Array<{
    index: number;
    text: string;
    durationSec?: number;
    imageUrl?: string;
    notes?: string;
  }>;
}
```

## Configuration

### Environment Variables

Set these in Firebase Functions config:

```bash
firebase functions:config:set \
  whisper.model="small" \
  whisper.device="cpu" \
  whisper.compute_type="int8"
```

### Resource Limits

- **Memory**: 2GB
- **Timeout**: 9 minutes (540 seconds)
- **Region**: europe-central2
- **Max Instances**: 10

## Cost Optimization

- Uses `small` Whisper model for faster processing
- CPU-only inference to avoid GPU costs
- Deterministic recipe IDs prevent duplicate processing
- Efficient audio conversion with ffmpeg

## Error Handling

The function handles common errors:
- Invalid URLs
- Unsupported video formats
- Audio extraction failures
- Transcription errors
- Network timeouts

## Monitoring

Monitor function performance in:
- Firebase Console → Functions
- Cloud Logging
- Cloud Monitoring

Key metrics to track:
- Execution time
- Memory usage
- Error rates
- Cold start frequency

## Security

- Requires Firebase Authentication
- Validates input parameters
- Sanitizes extracted text
- Rate limiting via Firestore rules
- No sensitive data in logs

## Troubleshooting

### Common Issues

1. **Audio download fails**: Check if yt-dlp supports the URL format
2. **Transcription timeout**: Reduce audio length or increase timeout
3. **Memory errors**: Increase memory allocation or optimize model size
4. **Cold starts**: Consider keeping instances warm for production

### Debug Mode

Enable debug logging:
```bash
firebase functions:config:set debug.enabled=true
```

## Performance Tips

1. Use containerized deployment for better resource control
2. Implement caching for frequently requested recipes
3. Consider using Cloud CDN for static assets
4. Monitor and optimize memory usage
5. Use regional deployment for lower latency
