// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Activity _$ActivityFromJson(Map<String, dynamic> json) => _Activity(
      key: json['key'] as String,
      activity: json['activity'] as String,
      type: json['type'] as String,
      participant: (json['participant'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$ActivityToJson(_Activity instance) => <String, dynamic>{
      'key': instance.key,
      'activity': instance.activity,
      'type': instance.type,
      'participant': instance.participant,
      'price': instance.price,
    };
