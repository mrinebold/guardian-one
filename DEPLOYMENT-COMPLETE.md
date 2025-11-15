# Guardian One Deployment - COMPLETE ✅

**Live URL**: https://guardianone.msrresearch.com/
**Deployed**: November 15, 2025, 4:17 PM UTC
**Status**: ✅ FULLY OPERATIONAL

---

## 🌐 Infrastructure Setup

### Cloudflare Tunnel
- **Tunnel**: `civicgrants-multi-site` (f761d607-b76c-493c-9885-06f6f76e5f38)
- **DNS**: guardianone.msrresearch.com → CNAME to tunnel
- **SSL**: Automatic via Cloudflare

### Nginx Configuration
- **Config**: `/etc/nginx/sites-available/multi-site`
- **Upstream**: `guardianone_app` → localhost:5176
- **Server Block**: guardianone.msrresearch.com
- **Features**:
  - Vite HMR WebSocket support
  - Rate limiting (500r/s for assets)
  - Security headers
  - API proxy to backend (port 8000)

### Vite Dev Server
- **Port**: 5176
- **Allowed Hosts**: localhost, guardianone.msrresearch.com
- **Status**: Running in background
- **HMR**: Enabled for live reload during development

---

## 📁 Configuration Files

### `/etc/nginx/sites-available/multi-site`
```nginx
# Guardian One webapp upstream (Vite dev server)
upstream guardianone_app {
    server localhost:5176;
    keepalive 32;
}

# 7. Guardian One - Aviation Safety Demo
server {
    listen 80;
    server_name guardianone.msrresearch.com;
    
    # API endpoints (Guardian One backend)
    location /api/ {
        proxy_pass http://civicgrants_api;
        # ... proxy headers and timeouts
    }
    
    # Vite HMR support
    location ~ ^/(src/|@vite/|@fs/) {
        proxy_pass http://guardianone_app;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # Frontend
    location / {
        proxy_pass http://guardianone_app;
        # ... WebSocket support for HMR
    }
}
```

### `/etc/cloudflared/config.yml`
```yaml
ingress:
  # ... other sites ...
  - hostname: guardianone.msrresearch.com
    service: http://localhost:80
    originRequest:
      noTLSVerify: true
      connectTimeout: 10s
      tlsTimeout: 5s
      keepaliveTimeout: 90s
  # ... fallback ...
```

### `/home/mrinebold/dev/guardian-one/webapp/vite.config.ts`
```typescript
export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 5176,
    allowedHosts: [
      'localhost',
      'guardianone.msrresearch.com',
    ],
  },
})
```

---

## 🚀 Deployment Steps Completed

1. ✅ Created Vite + React + TypeScript webapp
2. ✅ Added Guardian One to nginx multi-site config
3. ✅ Added upstream for port 5176
4. ✅ Configured Vite allowed hosts
5. ✅ Updated Cloudflare tunnel ingress rules
6. ✅ Added DNS CNAME record via cloudflared CLI
7. ✅ Restarted nginx and cloudflared services
8. ✅ Verified live site accessibility

---

## 🔧 Maintenance Commands

### Check Guardian One Service Status
```bash
# Check Vite dev server
ps aux | grep "vite.*guardian-one"
ss -tlnp | grep :5176

# Check nginx
sudo nginx -t
sudo systemctl status nginx

# Check Cloudflare tunnel
sudo systemctl status cloudflared
cloudflared tunnel info civicgrants-multi-site
```

### Restart Services
```bash
# Restart Vite dev server
cd /home/mrinebold/dev/guardian-one/webapp
npm run dev &

# Reload nginx (after config changes)
sudo nginx -t && sudo systemctl reload nginx

# Restart Cloudflare tunnel (after config changes)
sudo systemctl restart cloudflared
```

### View Logs
```bash
# Nginx access/error logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Cloudflare tunnel logs
sudo journalctl -u cloudflared -f
```

---

## 🎯 What's Live

### Star Wars Opening Crawl
- **URL**: https://guardianone.msrresearch.com/
- **Duration**: 90 seconds
- **Features**: 3D CSS animation, starfield, agent showcase
- **Skip**: Button in top-right corner
- **Launch**: Press ENTER after crawl

### Guardian One App
- **GPS Tracking**: Real-time location with Leaflet maps
- **AI Weather**: GPT-4 powered METAR/TAF analysis
- **Flight Logging**: 6 engine parameters per flight
- **Trend Analysis**: 10-flight trend charts
- **Flight History**: Complete log with engine data

---

## 🔗 Backend Integration

Guardian One webapp uses the existing Guardian One FastAPI backend:
- **Backend**: http://localhost:8000 (proxied via nginx)
- **Repository**: `/home/mrinebold/dev/guardian-one/backend`
- **Status**: Must be running for weather and flight features

Start backend if needed:
```bash
cd /home/mrinebold/dev/guardian-one/backend
python -m uvicorn main:app --reload --port 8000
```

---

## 📝 Files Created/Modified

### New Files
- `/home/mrinebold/dev/guardian-one/webapp/*` - Complete React webapp
- `/home/mrinebold/dev/guardian-one/webapp/README.md` - Webapp documentation
- `/home/mrinebold/dev/guardian-one/DEPLOYMENT-COMPLETE.md` - This file

### Modified Files
- `/etc/nginx/sites-available/multi-site` - Added Guardian One server block
- `/etc/cloudflared/config.yml` - Added guardianone.msrresearch.com ingress
- DNS: Added CNAME record via Cloudflare API

---

## ✅ Verification Checklist

- [x] DNS resolves to Cloudflare IPs
- [x] HTTPS certificate valid (Cloudflare auto-cert)
- [x] Nginx proxy working (tested with curl)
- [x] Vite dev server responding on port 5176
- [x] Star Wars crawl loads and animates
- [x] WebSocket HMR connections work
- [x] Site accessible at https://guardianone.msrresearch.com/

---

**Deployment completed successfully!**

Guardian One is now live and accessible to Dustin and other pilots for Day 10 demo testing.

Built by Saladbar AI Agent Platform  
MSR Research © 2025

*May the code be with you.* ✈️
