# Deploying Party Jukebox to Render

This guide will help you deploy your Party Jukebox application to Render.

## Prerequisites

- A GitHub account with this repository pushed
- A Render account (free tier works)
- A YouTube API key

## Quick Deploy with render.yaml

1. **Push your code to GitHub**
   ```bash
   git add .
   git commit -m "Add deployment configuration"
   git push
   ```

2. **Create a new Blueprint on Render**
   - Go to https://dashboard.render.com/
   - Click "New" → "Blueprint"
   - Connect your GitHub repository
   - Render will automatically detect `render.yaml` and set up:
     - PostgreSQL database
     - Web service with Docker

3. **Configure Environment Variables**

   After the blueprint is created, you need to set these environment variables in the Render dashboard:

   ### Required Variables:

   - **PHX_HOST**: Your Render app URL (e.g., `your-app-name.onrender.com`)
     - Find this in your service settings after creation
     - Set this BEFORE the first deployment

   - **YOUTUBE_API_KEY**: Your YouTube Data API v3 key
     - Get one from: https://console.cloud.google.com/apis/credentials
     - Enable YouTube Data API v3 for your project

   ### Auto-configured Variables:
   These are set automatically by Render:
   - `DATABASE_URL` - Connected from the PostgreSQL database
   - `SECRET_KEY_BASE` - Auto-generated secure key
   - `POOL_SIZE` - Set to 2 (for free tier)

4. **Run Database Migrations**

   After the first successful build, you need to run migrations:

   - Go to your service's "Shell" tab in Render
   - Run: `/app/bin/migrate`

   Or add this as a release command in your `render.yaml` service configuration:
   ```yaml
   buildCommand: ./bin/migrate
   ```

5. **Access Your App**

   Your app will be available at: `https://your-app-name.onrender.com`

## Manual Deployment (Alternative)

If you prefer not to use the Blueprint:

1. **Create PostgreSQL Database**
   - New → PostgreSQL
   - Choose free tier
   - Name: `party_jukebox_db`

2. **Create Web Service**
   - New → Web Service
   - Connect your repository
   - Settings:
     - Name: `party-jukebox`
     - Runtime: Docker
     - Plan: Free

3. **Configure Environment Variables** (same as step 3 above)

4. **Run Migrations** (same as step 4 above)

## Troubleshooting

### Build Fails
- Check that all dependencies in `mix.exs` are available
- Verify Dockerfile is using correct Elixir/Erlang versions

### App Crashes on Start
- Verify `PHX_HOST` is set correctly
- Check `DATABASE_URL` is connected
- View logs in Render dashboard

### Database Connection Issues
- Ensure PostgreSQL database is running
- Check `DATABASE_URL` format is correct
- Verify `POOL_SIZE` is appropriate (2 for free tier)

### YouTube Search Not Working
- Verify `YOUTUBE_API_KEY` is set
- Check API key has YouTube Data API v3 enabled
- Ensure API key isn't restricted to specific IPs

## Cost Considerations

**Free Tier Limitations:**
- Web service spins down after 15 minutes of inactivity
- First request after spin-down will be slow (~30 seconds)
- 750 hours/month free compute
- Database has 1GB storage limit

**Upgrade Options:**
- Starter plan ($7/month) keeps service always running
- More database storage and connection pooling

## Updating Your App

To deploy updates:

```bash
git add .
git commit -m "Your update message"
git push
```

Render will automatically rebuild and redeploy your application.

## Database Backups

Render automatically backs up PostgreSQL databases on paid plans. For free tier, consider:
- Periodic manual exports via Render shell
- Using `pg_dump` to save backups

## Next Steps

After deployment:
- Test creating a party
- Verify QR codes work with production URL
- Test YouTube search functionality
- Share your party with friends!
