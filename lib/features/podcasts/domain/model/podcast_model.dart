import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PodcastModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String audioUrl;
  final String author;
  final int duration;
  final int likes;
  final int plays;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String languageCode;

  const PodcastModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.audioUrl,
    required this.author,
    required this.duration,
    required this.likes,
    required this.plays,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
    required this.languageCode,
  });

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  factory PodcastModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return PodcastModel(
      id: snapshot.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      author: data['author'] ?? '',
      duration: data['duration'] ?? 0,
      likes: data['likes'] ?? 0,
      plays: data['plays'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      languageCode: data['languageCode'] ?? 'en',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'author': author,
      'duration': duration,
      'likes': likes,
      'plays': plays,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'languageCode': languageCode,
    };
  }

  PodcastModel copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? audioUrl,
    String? author,
    int? duration,
    int? likes,
    int? plays,
    List<String>? tags,
    DateTime? updatedAt,
    String? languageCode,
  }) {
    return PodcastModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      author: author ?? this.author,
      duration: duration ?? this.duration,
      likes: likes ?? this.likes,
      plays: plays ?? this.plays,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        audioUrl,
        author,
        duration,
        likes,
        plays,
        tags,
        createdAt,
        updatedAt,
        languageCode,
      ];
}
