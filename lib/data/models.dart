/// **Core Data Models for AI Chat Template**
///
/// This file defines the fundamental data structures that power the chat application.
/// All models are designed to be simple, serializable, and extensible.

/// Defines whether a message comes from the user or AI assistant
enum MessageRole { user, assistant }

/// **Message** - Core chat message model
///
/// Represents a single message in a conversation thread. Messages are immutable
/// and contain all necessary metadata for rendering and persistence.
///
/// ## Design Notes:
/// - `content` supports Markdown formatting for rich text rendering
/// - `id` should be unique within the conversation scope
/// - `timestamp` enables proper message ordering and time displays
///
/// ## Extension Examples:
/// ```dart
/// // Add message metadata:
/// class ExtendedMessage extends Message {
///   final Map<String, dynamic>? metadata;
///   final List<String>? attachments;
/// }
///
/// // Add message reactions:
/// class ReactableMessage extends Message {
///   final Map<String, int> reactions;
/// }
/// ```
class Message {
  final String id;
  final MessageRole role;
  final String content; // markdown/plaintext; rich parts later
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });
}

/// **Conversation** - Container for a chat thread
///
/// Groups related messages together and maintains conversation metadata.
/// Conversations are mutable to support real-time updates during chat.
///
/// ## Usage Pattern:
/// - Create new conversations via `ChatProvider.createNewConversation()`
/// - Messages are appended during chat interactions
/// - `title` is auto-generated from first message or can be customized
/// - `lastUpdated` drives conversation sorting in sidebar
///
/// ## Extension Ideas:
/// ```dart
/// // Add conversation settings:
/// class ExtendedConversation extends Conversation {
///   final String? systemPrompt;
///   final Map<String, dynamic>? settings;
/// }
///
/// // Add sharing and collaboration:
/// class SharedConversation extends Conversation {
///   final List<String> participantIds;
///   final bool isPublic;
/// }
/// ```
class Conversation {
  final String id;
  String title; // Mutable - auto-generated or user-customized
  final List<Message> messages; // Mutable - messages added during chat
  DateTime lastUpdated; // Mutable - updated on each interaction

  Conversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.lastUpdated,
  });
}

class SourceLink {
  final String id;
  final String title;
  final String url;
  final String snippet;
  const SourceLink({
    required this.id,
    required this.title,
    required this.url,
    required this.snippet,
  });
}

class ModelInfo {
  final String id;
  final String label;
  const ModelInfo({required this.id, required this.label});
}

class AIProvider {
  final String id;
  final String name;
  final String baseUrl;
  final String apiKey;
  final bool isEnabled;
  final bool isBuiltIn;
  final List<String> models;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AIProvider({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.apiKey,
    this.isEnabled = true,
    this.isBuiltIn = false,
    required this.models,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'baseUrl': baseUrl,
    'apiKey': apiKey,
    'isEnabled': isEnabled,
    'isBuiltIn': isBuiltIn,
    'models': models,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory AIProvider.fromJson(Map<String, dynamic> json) => AIProvider(
    id: json['id'] as String,
    name: json['name'] as String,
    baseUrl: json['baseUrl'] as String,
    apiKey: json['apiKey'] as String,
    isEnabled: json['isEnabled'] as bool? ?? true,
    isBuiltIn: json['isBuiltIn'] as bool? ?? false,
    models: (json['models'] as List?)?.cast<String>() ?? [],
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  AIProvider copyWith({
    String? id,
    String? name,
    String? baseUrl,
    String? apiKey,
    bool? isEnabled,
    bool? isBuiltIn,
    List<String>? models,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AIProvider(
    id: id ?? this.id,
    name: name ?? this.name,
    baseUrl: baseUrl ?? this.baseUrl,
    apiKey: apiKey ?? this.apiKey,
    isEnabled: isEnabled ?? this.isEnabled,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    models: models ?? this.models,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

class TTSSettings {
  final String provider;
  final String modelId;
  final double volume;
  final double pitch;
  final double rate;
  final String language;
  final bool autoPlay;

  const TTSSettings({
    required this.provider,
    required this.modelId,
    this.volume = 1.0,
    this.pitch = 1.0,
    this.rate = 0.5,
    this.language = 'en-US',
    this.autoPlay = false,
  });

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'modelId': modelId,
    'volume': volume,
    'pitch': pitch,
    'rate': rate,
    'language': language,
    'autoPlay': autoPlay,
  };

  factory TTSSettings.fromJson(Map<String, dynamic> json) => TTSSettings(
    provider: json['provider'] as String? ?? 'system',
    modelId: json['modelId'] as String? ?? '',
    volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
    pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0,
    rate: (json['rate'] as num?)?.toDouble() ?? 0.5,
    language: json['language'] as String? ?? 'en-US',
    autoPlay: json['autoPlay'] as bool? ?? false,
  );

  TTSSettings copyWith({
    String? provider,
    String? modelId,
    double? volume,
    double? pitch,
    double? rate,
    String? language,
    bool? autoPlay,
  }) => TTSSettings(
    provider: provider ?? this.provider,
    modelId: modelId ?? this.modelId,
    volume: volume ?? this.volume,
    pitch: pitch ?? this.pitch,
    rate: rate ?? this.rate,
    language: language ?? this.language,
    autoPlay: autoPlay ?? this.autoPlay,
  );
}

class MCPServer {
  final String id;
  final String name;
  final String url;
  final String? apiKey;
  final bool isEnabled;
  final Map<String, dynamic> config;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MCPServer({
    required this.id,
    required this.name,
    required this.url,
    this.apiKey,
    required this.isEnabled,
    required this.config,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'apiKey': apiKey,
    'isEnabled': isEnabled,
    'config': config,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory MCPServer.fromJson(Map<String, dynamic> json) => MCPServer(
    id: json['id'] as String,
    name: json['name'] as String,
    url: json['url'] as String,
    apiKey: json['apiKey'] as String?,
    isEnabled: json['isEnabled'] as bool? ?? true,
    config: json['config'] as Map<String, dynamic>? ?? {},
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  MCPServer copyWith({
    String? id,
    String? name,
    String? url,
    String? apiKey,
    bool? isEnabled,
    Map<String, dynamic>? config,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MCPServer(
    id: id ?? this.id,
    name: name ?? this.name,
    url: url ?? this.url,
    apiKey: apiKey ?? this.apiKey,
    isEnabled: isEnabled ?? this.isEnabled,
    config: config ?? this.config,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

enum TaskStatus { pending, inProgress, complete, failed }

class TaskItem {
  final String id;
  final String title;
  final TaskStatus status;
  final double progress; // 0..1
  final String? details;
  const TaskItem({
    required this.id,
    required this.title,
    this.status = TaskStatus.pending,
    this.progress = 0.0,
    this.details,
  });
}

class ToolUiPart {
  final String type;
  final String title;
  final String content;
  const ToolUiPart({
    required this.type,
    required this.title,
    required this.content,
  });
}

/// **ChatStatus** - Tracks the current state of chat interactions
///
/// Used by `ChatProvider` and UI widgets to coordinate loading states,
/// disable inputs during processing, and show appropriate indicators.
///
/// ## States:
/// - `idle`: Ready for new messages
/// - `submitting`: Processing user input (brief state)
/// - `streaming`: Receiving AI response in real-time
/// - `error`: Failed interaction (temporary state)
///
/// ## Usage in Widgets:
/// ```dart
/// // Disable send button during processing:
/// final isProcessing = chatProvider.status != ChatStatus.idle;
///
/// // Show loading indicator:
/// if (chatProvider.status == ChatStatus.streaming) {
///   return LoadingIndicator();
/// }
///
/// // Show error state:
/// if (chatProvider.status == ChatStatus.error) {
///   return ErrorWidget();
/// }
/// ```
enum ChatStatus { idle, submitting, streaming, error }
