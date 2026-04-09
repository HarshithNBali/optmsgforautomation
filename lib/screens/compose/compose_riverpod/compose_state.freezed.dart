// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compose_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ComposeAttachment {

 String get fileName; String get fileType; String get serverPath; int get sizeBytes; bool get isUploading; double get uploadProgress; String? get error;
/// Create a copy of ComposeAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComposeAttachmentCopyWith<ComposeAttachment> get copyWith => _$ComposeAttachmentCopyWithImpl<ComposeAttachment>(this as ComposeAttachment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComposeAttachment&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.fileType, fileType) || other.fileType == fileType)&&(identical(other.serverPath, serverPath) || other.serverPath == serverPath)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.isUploading, isUploading) || other.isUploading == isUploading)&&(identical(other.uploadProgress, uploadProgress) || other.uploadProgress == uploadProgress)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,fileName,fileType,serverPath,sizeBytes,isUploading,uploadProgress,error);

@override
String toString() {
  return 'ComposeAttachment(fileName: $fileName, fileType: $fileType, serverPath: $serverPath, sizeBytes: $sizeBytes, isUploading: $isUploading, uploadProgress: $uploadProgress, error: $error)';
}


}

/// @nodoc
abstract mixin class $ComposeAttachmentCopyWith<$Res>  {
  factory $ComposeAttachmentCopyWith(ComposeAttachment value, $Res Function(ComposeAttachment) _then) = _$ComposeAttachmentCopyWithImpl;
@useResult
$Res call({
 String fileName, String fileType, String serverPath, int sizeBytes, bool isUploading, double uploadProgress, String? error
});




}
/// @nodoc
class _$ComposeAttachmentCopyWithImpl<$Res>
    implements $ComposeAttachmentCopyWith<$Res> {
  _$ComposeAttachmentCopyWithImpl(this._self, this._then);

  final ComposeAttachment _self;
  final $Res Function(ComposeAttachment) _then;

/// Create a copy of ComposeAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fileName = null,Object? fileType = null,Object? serverPath = null,Object? sizeBytes = null,Object? isUploading = null,Object? uploadProgress = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,fileType: null == fileType ? _self.fileType : fileType // ignore: cast_nullable_to_non_nullable
as String,serverPath: null == serverPath ? _self.serverPath : serverPath // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,isUploading: null == isUploading ? _self.isUploading : isUploading // ignore: cast_nullable_to_non_nullable
as bool,uploadProgress: null == uploadProgress ? _self.uploadProgress : uploadProgress // ignore: cast_nullable_to_non_nullable
as double,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ComposeAttachment].
extension ComposeAttachmentPatterns on ComposeAttachment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComposeAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComposeAttachment() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComposeAttachment value)  $default,){
final _that = this;
switch (_that) {
case _ComposeAttachment():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComposeAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _ComposeAttachment() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fileName,  String fileType,  String serverPath,  int sizeBytes,  bool isUploading,  double uploadProgress,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComposeAttachment() when $default != null:
return $default(_that.fileName,_that.fileType,_that.serverPath,_that.sizeBytes,_that.isUploading,_that.uploadProgress,_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fileName,  String fileType,  String serverPath,  int sizeBytes,  bool isUploading,  double uploadProgress,  String? error)  $default,) {final _that = this;
switch (_that) {
case _ComposeAttachment():
return $default(_that.fileName,_that.fileType,_that.serverPath,_that.sizeBytes,_that.isUploading,_that.uploadProgress,_that.error);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fileName,  String fileType,  String serverPath,  int sizeBytes,  bool isUploading,  double uploadProgress,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _ComposeAttachment() when $default != null:
return $default(_that.fileName,_that.fileType,_that.serverPath,_that.sizeBytes,_that.isUploading,_that.uploadProgress,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ComposeAttachment extends ComposeAttachment {
  const _ComposeAttachment({required this.fileName, required this.fileType, required this.serverPath, required this.sizeBytes, this.isUploading = false, this.uploadProgress = 0.0, this.error}): super._();
  

@override final  String fileName;
@override final  String fileType;
@override final  String serverPath;
@override final  int sizeBytes;
@override@JsonKey() final  bool isUploading;
@override@JsonKey() final  double uploadProgress;
@override final  String? error;

/// Create a copy of ComposeAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComposeAttachmentCopyWith<_ComposeAttachment> get copyWith => __$ComposeAttachmentCopyWithImpl<_ComposeAttachment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComposeAttachment&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.fileType, fileType) || other.fileType == fileType)&&(identical(other.serverPath, serverPath) || other.serverPath == serverPath)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.isUploading, isUploading) || other.isUploading == isUploading)&&(identical(other.uploadProgress, uploadProgress) || other.uploadProgress == uploadProgress)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,fileName,fileType,serverPath,sizeBytes,isUploading,uploadProgress,error);

@override
String toString() {
  return 'ComposeAttachment(fileName: $fileName, fileType: $fileType, serverPath: $serverPath, sizeBytes: $sizeBytes, isUploading: $isUploading, uploadProgress: $uploadProgress, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ComposeAttachmentCopyWith<$Res> implements $ComposeAttachmentCopyWith<$Res> {
  factory _$ComposeAttachmentCopyWith(_ComposeAttachment value, $Res Function(_ComposeAttachment) _then) = __$ComposeAttachmentCopyWithImpl;
@override @useResult
$Res call({
 String fileName, String fileType, String serverPath, int sizeBytes, bool isUploading, double uploadProgress, String? error
});




}
/// @nodoc
class __$ComposeAttachmentCopyWithImpl<$Res>
    implements _$ComposeAttachmentCopyWith<$Res> {
  __$ComposeAttachmentCopyWithImpl(this._self, this._then);

  final _ComposeAttachment _self;
  final $Res Function(_ComposeAttachment) _then;

/// Create a copy of ComposeAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fileName = null,Object? fileType = null,Object? serverPath = null,Object? sizeBytes = null,Object? isUploading = null,Object? uploadProgress = null,Object? error = freezed,}) {
  return _then(_ComposeAttachment(
fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,fileType: null == fileType ? _self.fileType : fileType // ignore: cast_nullable_to_non_nullable
as String,serverPath: null == serverPath ? _self.serverPath : serverPath // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,isUploading: null == isUploading ? _self.isUploading : isUploading // ignore: cast_nullable_to_non_nullable
as bool,uploadProgress: null == uploadProgress ? _self.uploadProgress : uploadProgress // ignore: cast_nullable_to_non_nullable
as double,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ComposeState {

// Mode
 ComposeMode get mode; int? get emailId; int? get draftId;// Recipients
 List<String> get toRecipients; List<String> get ccRecipients; List<String> get bccRecipients; bool get showCcBcc;// Content
 String get subject; String get bodyHtml; String? get quotedHtml;// Sender
 String get fromEmail; String get fromName;// Attachments
 List<ComposeAttachment> get attachments; int get totalAttachmentBytes;// Flags
 bool get isLoading; bool get isSending; bool get isSavingDraft; bool get isDirty; bool get hasLocalBackup;// Send lifecycle
 SendStatus get sendStatus; int? get sentEmailId; List<String> get failedRecipients;// Error
 String? get error;// User data
 Map<String, dynamic>? get userData; String get token;
/// Create a copy of ComposeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComposeStateCopyWith<ComposeState> get copyWith => _$ComposeStateCopyWithImpl<ComposeState>(this as ComposeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComposeState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.emailId, emailId) || other.emailId == emailId)&&(identical(other.draftId, draftId) || other.draftId == draftId)&&const DeepCollectionEquality().equals(other.toRecipients, toRecipients)&&const DeepCollectionEquality().equals(other.ccRecipients, ccRecipients)&&const DeepCollectionEquality().equals(other.bccRecipients, bccRecipients)&&(identical(other.showCcBcc, showCcBcc) || other.showCcBcc == showCcBcc)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.bodyHtml, bodyHtml) || other.bodyHtml == bodyHtml)&&(identical(other.quotedHtml, quotedHtml) || other.quotedHtml == quotedHtml)&&(identical(other.fromEmail, fromEmail) || other.fromEmail == fromEmail)&&(identical(other.fromName, fromName) || other.fromName == fromName)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.totalAttachmentBytes, totalAttachmentBytes) || other.totalAttachmentBytes == totalAttachmentBytes)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.isSavingDraft, isSavingDraft) || other.isSavingDraft == isSavingDraft)&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty)&&(identical(other.hasLocalBackup, hasLocalBackup) || other.hasLocalBackup == hasLocalBackup)&&(identical(other.sendStatus, sendStatus) || other.sendStatus == sendStatus)&&(identical(other.sentEmailId, sentEmailId) || other.sentEmailId == sentEmailId)&&const DeepCollectionEquality().equals(other.failedRecipients, failedRecipients)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.userData, userData)&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode => Object.hashAll([runtimeType,mode,emailId,draftId,const DeepCollectionEquality().hash(toRecipients),const DeepCollectionEquality().hash(ccRecipients),const DeepCollectionEquality().hash(bccRecipients),showCcBcc,subject,bodyHtml,quotedHtml,fromEmail,fromName,const DeepCollectionEquality().hash(attachments),totalAttachmentBytes,isLoading,isSending,isSavingDraft,isDirty,hasLocalBackup,sendStatus,sentEmailId,const DeepCollectionEquality().hash(failedRecipients),error,const DeepCollectionEquality().hash(userData),token]);

@override
String toString() {
  return 'ComposeState(mode: $mode, emailId: $emailId, draftId: $draftId, toRecipients: $toRecipients, ccRecipients: $ccRecipients, bccRecipients: $bccRecipients, showCcBcc: $showCcBcc, subject: $subject, bodyHtml: $bodyHtml, quotedHtml: $quotedHtml, fromEmail: $fromEmail, fromName: $fromName, attachments: $attachments, totalAttachmentBytes: $totalAttachmentBytes, isLoading: $isLoading, isSending: $isSending, isSavingDraft: $isSavingDraft, isDirty: $isDirty, hasLocalBackup: $hasLocalBackup, sendStatus: $sendStatus, sentEmailId: $sentEmailId, failedRecipients: $failedRecipients, error: $error, userData: $userData, token: $token)';
}


}

/// @nodoc
abstract mixin class $ComposeStateCopyWith<$Res>  {
  factory $ComposeStateCopyWith(ComposeState value, $Res Function(ComposeState) _then) = _$ComposeStateCopyWithImpl;
@useResult
$Res call({
 ComposeMode mode, int? emailId, int? draftId, List<String> toRecipients, List<String> ccRecipients, List<String> bccRecipients, bool showCcBcc, String subject, String bodyHtml, String? quotedHtml, String fromEmail, String fromName, List<ComposeAttachment> attachments, int totalAttachmentBytes, bool isLoading, bool isSending, bool isSavingDraft, bool isDirty, bool hasLocalBackup, SendStatus sendStatus, int? sentEmailId, List<String> failedRecipients, String? error, Map<String, dynamic>? userData, String token
});




}
/// @nodoc
class _$ComposeStateCopyWithImpl<$Res>
    implements $ComposeStateCopyWith<$Res> {
  _$ComposeStateCopyWithImpl(this._self, this._then);

  final ComposeState _self;
  final $Res Function(ComposeState) _then;

/// Create a copy of ComposeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? emailId = freezed,Object? draftId = freezed,Object? toRecipients = null,Object? ccRecipients = null,Object? bccRecipients = null,Object? showCcBcc = null,Object? subject = null,Object? bodyHtml = null,Object? quotedHtml = freezed,Object? fromEmail = null,Object? fromName = null,Object? attachments = null,Object? totalAttachmentBytes = null,Object? isLoading = null,Object? isSending = null,Object? isSavingDraft = null,Object? isDirty = null,Object? hasLocalBackup = null,Object? sendStatus = null,Object? sentEmailId = freezed,Object? failedRecipients = null,Object? error = freezed,Object? userData = freezed,Object? token = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ComposeMode,emailId: freezed == emailId ? _self.emailId : emailId // ignore: cast_nullable_to_non_nullable
as int?,draftId: freezed == draftId ? _self.draftId : draftId // ignore: cast_nullable_to_non_nullable
as int?,toRecipients: null == toRecipients ? _self.toRecipients : toRecipients // ignore: cast_nullable_to_non_nullable
as List<String>,ccRecipients: null == ccRecipients ? _self.ccRecipients : ccRecipients // ignore: cast_nullable_to_non_nullable
as List<String>,bccRecipients: null == bccRecipients ? _self.bccRecipients : bccRecipients // ignore: cast_nullable_to_non_nullable
as List<String>,showCcBcc: null == showCcBcc ? _self.showCcBcc : showCcBcc // ignore: cast_nullable_to_non_nullable
as bool,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,bodyHtml: null == bodyHtml ? _self.bodyHtml : bodyHtml // ignore: cast_nullable_to_non_nullable
as String,quotedHtml: freezed == quotedHtml ? _self.quotedHtml : quotedHtml // ignore: cast_nullable_to_non_nullable
as String?,fromEmail: null == fromEmail ? _self.fromEmail : fromEmail // ignore: cast_nullable_to_non_nullable
as String,fromName: null == fromName ? _self.fromName : fromName // ignore: cast_nullable_to_non_nullable
as String,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<ComposeAttachment>,totalAttachmentBytes: null == totalAttachmentBytes ? _self.totalAttachmentBytes : totalAttachmentBytes // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,isSavingDraft: null == isSavingDraft ? _self.isSavingDraft : isSavingDraft // ignore: cast_nullable_to_non_nullable
as bool,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,hasLocalBackup: null == hasLocalBackup ? _self.hasLocalBackup : hasLocalBackup // ignore: cast_nullable_to_non_nullable
as bool,sendStatus: null == sendStatus ? _self.sendStatus : sendStatus // ignore: cast_nullable_to_non_nullable
as SendStatus,sentEmailId: freezed == sentEmailId ? _self.sentEmailId : sentEmailId // ignore: cast_nullable_to_non_nullable
as int?,failedRecipients: null == failedRecipients ? _self.failedRecipients : failedRecipients // ignore: cast_nullable_to_non_nullable
as List<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,userData: freezed == userData ? _self.userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ComposeState].
extension ComposeStatePatterns on ComposeState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComposeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComposeState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComposeState value)  $default,){
final _that = this;
switch (_that) {
case _ComposeState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComposeState value)?  $default,){
final _that = this;
switch (_that) {
case _ComposeState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ComposeMode mode,  int? emailId,  int? draftId,  List<String> toRecipients,  List<String> ccRecipients,  List<String> bccRecipients,  bool showCcBcc,  String subject,  String bodyHtml,  String? quotedHtml,  String fromEmail,  String fromName,  List<ComposeAttachment> attachments,  int totalAttachmentBytes,  bool isLoading,  bool isSending,  bool isSavingDraft,  bool isDirty,  bool hasLocalBackup,  SendStatus sendStatus,  int? sentEmailId,  List<String> failedRecipients,  String? error,  Map<String, dynamic>? userData,  String token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComposeState() when $default != null:
return $default(_that.mode,_that.emailId,_that.draftId,_that.toRecipients,_that.ccRecipients,_that.bccRecipients,_that.showCcBcc,_that.subject,_that.bodyHtml,_that.quotedHtml,_that.fromEmail,_that.fromName,_that.attachments,_that.totalAttachmentBytes,_that.isLoading,_that.isSending,_that.isSavingDraft,_that.isDirty,_that.hasLocalBackup,_that.sendStatus,_that.sentEmailId,_that.failedRecipients,_that.error,_that.userData,_that.token);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ComposeMode mode,  int? emailId,  int? draftId,  List<String> toRecipients,  List<String> ccRecipients,  List<String> bccRecipients,  bool showCcBcc,  String subject,  String bodyHtml,  String? quotedHtml,  String fromEmail,  String fromName,  List<ComposeAttachment> attachments,  int totalAttachmentBytes,  bool isLoading,  bool isSending,  bool isSavingDraft,  bool isDirty,  bool hasLocalBackup,  SendStatus sendStatus,  int? sentEmailId,  List<String> failedRecipients,  String? error,  Map<String, dynamic>? userData,  String token)  $default,) {final _that = this;
switch (_that) {
case _ComposeState():
return $default(_that.mode,_that.emailId,_that.draftId,_that.toRecipients,_that.ccRecipients,_that.bccRecipients,_that.showCcBcc,_that.subject,_that.bodyHtml,_that.quotedHtml,_that.fromEmail,_that.fromName,_that.attachments,_that.totalAttachmentBytes,_that.isLoading,_that.isSending,_that.isSavingDraft,_that.isDirty,_that.hasLocalBackup,_that.sendStatus,_that.sentEmailId,_that.failedRecipients,_that.error,_that.userData,_that.token);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ComposeMode mode,  int? emailId,  int? draftId,  List<String> toRecipients,  List<String> ccRecipients,  List<String> bccRecipients,  bool showCcBcc,  String subject,  String bodyHtml,  String? quotedHtml,  String fromEmail,  String fromName,  List<ComposeAttachment> attachments,  int totalAttachmentBytes,  bool isLoading,  bool isSending,  bool isSavingDraft,  bool isDirty,  bool hasLocalBackup,  SendStatus sendStatus,  int? sentEmailId,  List<String> failedRecipients,  String? error,  Map<String, dynamic>? userData,  String token)?  $default,) {final _that = this;
switch (_that) {
case _ComposeState() when $default != null:
return $default(_that.mode,_that.emailId,_that.draftId,_that.toRecipients,_that.ccRecipients,_that.bccRecipients,_that.showCcBcc,_that.subject,_that.bodyHtml,_that.quotedHtml,_that.fromEmail,_that.fromName,_that.attachments,_that.totalAttachmentBytes,_that.isLoading,_that.isSending,_that.isSavingDraft,_that.isDirty,_that.hasLocalBackup,_that.sendStatus,_that.sentEmailId,_that.failedRecipients,_that.error,_that.userData,_that.token);case _:
  return null;

}
}

}

/// @nodoc


class _ComposeState extends ComposeState {
  const _ComposeState({this.mode = ComposeMode.newMessage, this.emailId, this.draftId, final  List<String> toRecipients = const [], final  List<String> ccRecipients = const [], final  List<String> bccRecipients = const [], this.showCcBcc = false, this.subject = '', this.bodyHtml = '', this.quotedHtml, this.fromEmail = '', this.fromName = '', final  List<ComposeAttachment> attachments = const [], this.totalAttachmentBytes = 0, this.isLoading = false, this.isSending = false, this.isSavingDraft = false, this.isDirty = false, this.hasLocalBackup = false, this.sendStatus = SendStatus.idle, this.sentEmailId, final  List<String> failedRecipients = const [], this.error, final  Map<String, dynamic>? userData, this.token = ''}): _toRecipients = toRecipients,_ccRecipients = ccRecipients,_bccRecipients = bccRecipients,_attachments = attachments,_failedRecipients = failedRecipients,_userData = userData,super._();
  

// Mode
@override@JsonKey() final  ComposeMode mode;
@override final  int? emailId;
@override final  int? draftId;
// Recipients
 final  List<String> _toRecipients;
// Recipients
@override@JsonKey() List<String> get toRecipients {
  if (_toRecipients is EqualUnmodifiableListView) return _toRecipients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_toRecipients);
}

 final  List<String> _ccRecipients;
@override@JsonKey() List<String> get ccRecipients {
  if (_ccRecipients is EqualUnmodifiableListView) return _ccRecipients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ccRecipients);
}

 final  List<String> _bccRecipients;
@override@JsonKey() List<String> get bccRecipients {
  if (_bccRecipients is EqualUnmodifiableListView) return _bccRecipients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bccRecipients);
}

@override@JsonKey() final  bool showCcBcc;
// Content
@override@JsonKey() final  String subject;
@override@JsonKey() final  String bodyHtml;
@override final  String? quotedHtml;
// Sender
@override@JsonKey() final  String fromEmail;
@override@JsonKey() final  String fromName;
// Attachments
 final  List<ComposeAttachment> _attachments;
// Attachments
@override@JsonKey() List<ComposeAttachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override@JsonKey() final  int totalAttachmentBytes;
// Flags
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isSending;
@override@JsonKey() final  bool isSavingDraft;
@override@JsonKey() final  bool isDirty;
@override@JsonKey() final  bool hasLocalBackup;
// Send lifecycle
@override@JsonKey() final  SendStatus sendStatus;
@override final  int? sentEmailId;
 final  List<String> _failedRecipients;
@override@JsonKey() List<String> get failedRecipients {
  if (_failedRecipients is EqualUnmodifiableListView) return _failedRecipients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_failedRecipients);
}

// Error
@override final  String? error;
// User data
 final  Map<String, dynamic>? _userData;
// User data
@override Map<String, dynamic>? get userData {
  final value = _userData;
  if (value == null) return null;
  if (_userData is EqualUnmodifiableMapView) return _userData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  String token;

/// Create a copy of ComposeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComposeStateCopyWith<_ComposeState> get copyWith => __$ComposeStateCopyWithImpl<_ComposeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComposeState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.emailId, emailId) || other.emailId == emailId)&&(identical(other.draftId, draftId) || other.draftId == draftId)&&const DeepCollectionEquality().equals(other._toRecipients, _toRecipients)&&const DeepCollectionEquality().equals(other._ccRecipients, _ccRecipients)&&const DeepCollectionEquality().equals(other._bccRecipients, _bccRecipients)&&(identical(other.showCcBcc, showCcBcc) || other.showCcBcc == showCcBcc)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.bodyHtml, bodyHtml) || other.bodyHtml == bodyHtml)&&(identical(other.quotedHtml, quotedHtml) || other.quotedHtml == quotedHtml)&&(identical(other.fromEmail, fromEmail) || other.fromEmail == fromEmail)&&(identical(other.fromName, fromName) || other.fromName == fromName)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.totalAttachmentBytes, totalAttachmentBytes) || other.totalAttachmentBytes == totalAttachmentBytes)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.isSavingDraft, isSavingDraft) || other.isSavingDraft == isSavingDraft)&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty)&&(identical(other.hasLocalBackup, hasLocalBackup) || other.hasLocalBackup == hasLocalBackup)&&(identical(other.sendStatus, sendStatus) || other.sendStatus == sendStatus)&&(identical(other.sentEmailId, sentEmailId) || other.sentEmailId == sentEmailId)&&const DeepCollectionEquality().equals(other._failedRecipients, _failedRecipients)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._userData, _userData)&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode => Object.hashAll([runtimeType,mode,emailId,draftId,const DeepCollectionEquality().hash(_toRecipients),const DeepCollectionEquality().hash(_ccRecipients),const DeepCollectionEquality().hash(_bccRecipients),showCcBcc,subject,bodyHtml,quotedHtml,fromEmail,fromName,const DeepCollectionEquality().hash(_attachments),totalAttachmentBytes,isLoading,isSending,isSavingDraft,isDirty,hasLocalBackup,sendStatus,sentEmailId,const DeepCollectionEquality().hash(_failedRecipients),error,const DeepCollectionEquality().hash(_userData),token]);

@override
String toString() {
  return 'ComposeState(mode: $mode, emailId: $emailId, draftId: $draftId, toRecipients: $toRecipients, ccRecipients: $ccRecipients, bccRecipients: $bccRecipients, showCcBcc: $showCcBcc, subject: $subject, bodyHtml: $bodyHtml, quotedHtml: $quotedHtml, fromEmail: $fromEmail, fromName: $fromName, attachments: $attachments, totalAttachmentBytes: $totalAttachmentBytes, isLoading: $isLoading, isSending: $isSending, isSavingDraft: $isSavingDraft, isDirty: $isDirty, hasLocalBackup: $hasLocalBackup, sendStatus: $sendStatus, sentEmailId: $sentEmailId, failedRecipients: $failedRecipients, error: $error, userData: $userData, token: $token)';
}


}

/// @nodoc
abstract mixin class _$ComposeStateCopyWith<$Res> implements $ComposeStateCopyWith<$Res> {
  factory _$ComposeStateCopyWith(_ComposeState value, $Res Function(_ComposeState) _then) = __$ComposeStateCopyWithImpl;
@override @useResult
$Res call({
 ComposeMode mode, int? emailId, int? draftId, List<String> toRecipients, List<String> ccRecipients, List<String> bccRecipients, bool showCcBcc, String subject, String bodyHtml, String? quotedHtml, String fromEmail, String fromName, List<ComposeAttachment> attachments, int totalAttachmentBytes, bool isLoading, bool isSending, bool isSavingDraft, bool isDirty, bool hasLocalBackup, SendStatus sendStatus, int? sentEmailId, List<String> failedRecipients, String? error, Map<String, dynamic>? userData, String token
});




}
/// @nodoc
class __$ComposeStateCopyWithImpl<$Res>
    implements _$ComposeStateCopyWith<$Res> {
  __$ComposeStateCopyWithImpl(this._self, this._then);

  final _ComposeState _self;
  final $Res Function(_ComposeState) _then;

/// Create a copy of ComposeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? emailId = freezed,Object? draftId = freezed,Object? toRecipients = null,Object? ccRecipients = null,Object? bccRecipients = null,Object? showCcBcc = null,Object? subject = null,Object? bodyHtml = null,Object? quotedHtml = freezed,Object? fromEmail = null,Object? fromName = null,Object? attachments = null,Object? totalAttachmentBytes = null,Object? isLoading = null,Object? isSending = null,Object? isSavingDraft = null,Object? isDirty = null,Object? hasLocalBackup = null,Object? sendStatus = null,Object? sentEmailId = freezed,Object? failedRecipients = null,Object? error = freezed,Object? userData = freezed,Object? token = null,}) {
  return _then(_ComposeState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ComposeMode,emailId: freezed == emailId ? _self.emailId : emailId // ignore: cast_nullable_to_non_nullable
as int?,draftId: freezed == draftId ? _self.draftId : draftId // ignore: cast_nullable_to_non_nullable
as int?,toRecipients: null == toRecipients ? _self._toRecipients : toRecipients // ignore: cast_nullable_to_non_nullable
as List<String>,ccRecipients: null == ccRecipients ? _self._ccRecipients : ccRecipients // ignore: cast_nullable_to_non_nullable
as List<String>,bccRecipients: null == bccRecipients ? _self._bccRecipients : bccRecipients // ignore: cast_nullable_to_non_nullable
as List<String>,showCcBcc: null == showCcBcc ? _self.showCcBcc : showCcBcc // ignore: cast_nullable_to_non_nullable
as bool,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,bodyHtml: null == bodyHtml ? _self.bodyHtml : bodyHtml // ignore: cast_nullable_to_non_nullable
as String,quotedHtml: freezed == quotedHtml ? _self.quotedHtml : quotedHtml // ignore: cast_nullable_to_non_nullable
as String?,fromEmail: null == fromEmail ? _self.fromEmail : fromEmail // ignore: cast_nullable_to_non_nullable
as String,fromName: null == fromName ? _self.fromName : fromName // ignore: cast_nullable_to_non_nullable
as String,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<ComposeAttachment>,totalAttachmentBytes: null == totalAttachmentBytes ? _self.totalAttachmentBytes : totalAttachmentBytes // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,isSavingDraft: null == isSavingDraft ? _self.isSavingDraft : isSavingDraft // ignore: cast_nullable_to_non_nullable
as bool,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,hasLocalBackup: null == hasLocalBackup ? _self.hasLocalBackup : hasLocalBackup // ignore: cast_nullable_to_non_nullable
as bool,sendStatus: null == sendStatus ? _self.sendStatus : sendStatus // ignore: cast_nullable_to_non_nullable
as SendStatus,sentEmailId: freezed == sentEmailId ? _self.sentEmailId : sentEmailId // ignore: cast_nullable_to_non_nullable
as int?,failedRecipients: null == failedRecipients ? _self._failedRecipients : failedRecipients // ignore: cast_nullable_to_non_nullable
as List<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,userData: freezed == userData ? _self._userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
