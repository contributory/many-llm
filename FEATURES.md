# Features Documentation

## Overview
This document provides detailed information about all features implemented in the many-llm Flutter web chat application.

## Core Features

### 1. Responsive Chat Interface
- **Mobile Support**: Fully responsive design with breakpoint at 768px
- **Drawer Navigation**: Collapsible sidebar on mobile devices
- **Animated Transitions**: Smooth sidebar animations on desktop
- **SafeArea Protection**: Content respects device notches and system bars
- **Proper Viewport**: Mobile-optimized viewport configuration

### 2. Conversation Management
- **Multiple Conversations**: Support for unlimited chat threads
- **Auto-naming**: AI-powered conversation title generation
- **Time Tracking**: Last updated timestamps for each conversation
- **Quick Actions**: Delete conversations, create new chats
- **Sorting**: Conversations sorted by most recent activity

### 3. AI Model Selection

#### Default Models (OpenRouter)
Built-in support for top-tier AI models:
- GPT-5, GPT-5 Mini, GPT-5 Nano
- ChatGPT 4o, GPT-4o Mini
- Claude Sonnet 4, Claude 3.7 Sonnet, Claude 3.5 Haiku
- Gemini 2.5 Flash Lite

#### Custom AI Providers ⭐ NEW
Add any OpenAI-compatible API provider:

**Adding a Provider:**
1. Navigate to Settings → Providers
2. Click "Add Provider"
3. Follow the 3-step wizard:
   - **Step 1**: Enter provider name (e.g., "OpenRouter", "DeepSeek", "Together AI")
   - **Step 2**: Configure connection
     - Base URL (e.g., `https://api.openai.com/v1`)
     - API Key
     - Click "Fetch Models" to auto-discover available models
   - **Step 3**: Review settings and optionally set as default provider

**Features:**
- ✅ Automatic model discovery from provider API
- ✅ Set default provider for new conversations
- ✅ API key masking for security
- ✅ Edit/delete existing providers
- ✅ Models immediately available in chat

**Supported Providers:**
Any OpenAI-compatible API endpoint:
- OpenRouter
- OpenAI
- Anthropic (via OpenAI-compatible wrapper)
- DeepSeek
- Together AI
- Groq
- Custom endpoints

### 4. Text-to-Speech (TTS) ⭐ NEW

Full-featured TTS implementation with system and AI voice support.

#### System TTS
- Uses device's built-in text-to-speech engine
- Voice and language selection
- Volume, pitch, and rate controls
- Test voice functionality

#### AI Provider TTS
- Use AI models for voice generation (when supported)
- Select TTS models from configured providers
- Advanced voice customization

#### Features:
- **Manual Playback**: Click speaker icon on any message
- **Auto-Play**: Toggle automatic speech for AI responses
- **Customization**: Full control over voice characteristics
  - Volume: 0-100%
  - Pitch: 0.5-2.0x
  - Speed: 0.0-1.0
- **Language Support**: Multiple languages available
- **Voice Selection**: Choose from available system voices
- **Persistent Settings**: All preferences saved automatically

#### Usage:
1. Go to Settings → TTS
2. Select TTS provider (System or custom AI)
3. Choose language and voice
4. Adjust volume, pitch, and speed to preference
5. Enable "Auto-play responses" for automatic speech
6. Click "Test Voice" to preview
7. In chat, click speaker icon on messages to hear them

### 5. MCP Server Management ⭐ NEW

Configure Model Context Protocol servers for extended functionality.

**Adding an MCP Server:**
1. Navigate to Settings → MCP Servers
2. Click "Add Server"
3. Enter details:
   - Server name
   - Server URL
   - API Key (optional)
   - Enable/disable toggle
4. Server configuration persists automatically

**Features:**
- ✅ Multiple MCP server support
- ✅ Enable/disable without deletion
- ✅ Optional API key authentication
- ✅ Edit existing servers
- ✅ Delete unwanted servers
- ✅ Persistent configuration

**Status**: UI and storage fully implemented. Protocol integration pending.

### 6. Theme Support
- **System Theme**: Respects OS dark/light mode
- **Light Theme**: Bright, clean interface
- **Dark Theme**: Reduced eye strain for night usage
- **Persistent**: Theme preference saved across sessions
- **Material 3**: Modern design system

### 7. Streaming Responses
- Real-time message streaming from AI
- Word-by-word display with typing indicator
- Stop generation button during streaming
- Markdown rendering with syntax highlighting
- Code block support with copy functionality

### 8. Message Actions
Available on all AI responses:
- **Regenerate**: Request new response (coming soon)
- **Thumbs Up/Down**: Provide feedback
- **Copy**: Copy message to clipboard
- **Speak**: Hear message with TTS
- **Share**: Share message content (coming soon)

### 9. Development Features

#### Mock Mode
When no API key is configured:
- Realistic mock responses with streaming
- Demo conversation capabilities
- Development-friendly testing environment
- No external dependencies required

#### API Configuration
Multiple backend options:
- **Direct Mode**: Client-side API calls (development)
- **Firebase Proxy**: Firebase Functions backend (production)
- **Supabase Proxy**: Supabase Edge Functions backend (production)

## Settings Management

All settings persist automatically in browser storage (SharedPreferences).

### Providers Settings
- Add/edit/delete AI providers
- Set default provider
- View available models per provider
- Manage API keys securely

### TTS Settings
- Choose TTS provider
- Select language and voice
- Adjust volume, pitch, speed
- Enable/disable auto-play
- Test voice settings

### MCP Servers Settings
- Add/edit/delete MCP servers
- Enable/disable servers
- Configure API authentication
- Manage server URLs

## Keyboard Shortcuts

### Chat Input
- **Enter**: New line
- **Ctrl+Enter / Cmd+Enter**: Send message
- **Escape**: Clear input (coming soon)

### Navigation
- Standard browser shortcuts work throughout

## Mobile Experience

### Optimizations
- ✅ Proper viewport configuration
- ✅ Touch-friendly UI elements
- ✅ Drawer navigation for small screens
- ✅ SafeArea for notched devices
- ✅ Responsive text sizing
- ✅ Mobile-optimized spacing

### Gestures
- Swipe to open/close sidebar (on mobile)
- Pull to scroll conversations
- Tap to interact with messages

## Performance

### Optimizations
- Efficient list rendering with ListView.builder
- Lazy loading of conversation history
- Optimized provider updates with notifyListeners
- Minimal re-renders with Consumer widgets
- Cached settings in memory

### Best Practices
- All user data stored locally
- No unnecessary API calls
- Streaming for real-time responses
- Debounced input where appropriate

## Security

### API Key Protection
- API keys masked in UI
- Never log API keys
- Recommend backend proxy for production
- Client-side keys only for development

### Data Privacy
- All conversations stored locally
- No server-side data collection
- User controls all data deletion
- SharedPreferences encrypted by browser

## Accessibility

### Features
- Proper contrast ratios in themes
- Screen reader support via semantic widgets
- Keyboard navigation throughout
- TTS for audio accessibility
- Focus management
- Tooltips on interactive elements

## Browser Support

### Tested Browsers
- ✅ Chrome/Chromium (Desktop & Mobile)
- ✅ Safari (Desktop & iOS)
- ✅ Firefox (Desktop)
- ✅ Edge (Desktop)

### Requirements
- Modern browser with ES6+ support
- Local storage enabled
- JavaScript enabled
- TTS requires Web Speech API support

## Coming Soon

### Planned Features
- [ ] File attachments support
- [ ] Image generation integration
- [ ] Conversation export/import
- [ ] Message search
- [ ] Conversation folders/tags
- [ ] Voice input (speech-to-text)
- [ ] Multi-language UI
- [ ] Message editing
- [ ] Conversation sharing
- [ ] Custom system prompts
- [ ] Token usage tracking
- [ ] Cost estimation
- [ ] Message bookmarking
- [ ] Keyboard shortcuts panel

### In Development
- MCP protocol integration
- Custom provider API routing
- Regenerate message functionality
- Share message feature
- Improved error handling

## Troubleshooting

### TTS Not Working
- Check browser supports Web Speech API
- Verify TTS settings are saved
- Try different voice selection
- Check device volume settings
- Test with "Test Voice" button

### Models Not Appearing
- Verify provider API key is correct
- Check base URL format (must include /v1)
- Ensure "Fetch Models" completed successfully
- Try editing and re-fetching models
- Check browser console for errors

### Settings Not Persisting
- Ensure browser allows local storage
- Check not in incognito/private mode
- Clear cache and try again
- Verify SharedPreferences not full

### Mobile Layout Issues
- Clear browser cache
- Check viewport settings in HTML
- Try different mobile browsers
- Report specific device/browser combo

## Support

For issues, feature requests, or contributions, please check the repository documentation.
