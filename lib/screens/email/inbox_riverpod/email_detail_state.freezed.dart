// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'email_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EmailDetailState {

 bool get isLoading; ViewEmailModel? get emailData; bool get showTagList; bool get showMenuOptions; bool get showAllAttachments; bool get markedAsUnread; bool get movedToArchive; bool get movedToTrash; List<EmailRecipientTags> get updatedTags; String? get error; Map<String, dynamic>? get userData; String get token; bool get newNotification; bool get fileDownloading; double get downloadProgress; bool get expandedView;
/// Create a copy of EmailDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmailDetailStateCopyWith<EmailDetailState> get copyWith => _$EmailDetailStateCopyWithImpl<EmailDetailState>(this as EmailDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailDetailState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.emailData, emailData) || other.emailData == emailData)&&(identical(other.showTagList, showTagList) || other.showTagList == showTagList)&&(identical(other.showMenuOptions, showMenuOptions) || other.showMenuOptions == showMenuOptions)&&(identical(other.showAllAttachments, showAllAttachments) || other.showAllAttachments == showAllAttachments)&&(identical(other.markedAsUnread, markedAsUnread) || other.markedAsUnread == markedAsUnread)&&(identical(other.movedToArchive, movedToArchive) || other.movedToArchive == movedToArchive)&&(identical(other.movedToTrash, movedToTrash) || other.movedToTrash == movedToTrash)&&const DeepCollectionEquality().equals(other.updatedTags, updatedTags)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.userData, userData)&&(identical(other.token, token) || other.token == token)&&(identical(other.newNotification, newNotification) || other.newNotification == newNotification)&&(identical(other.fileDownloading, fileDownloading) || other.fileDownloading == fileDownloading)&&(identical(other.downloadProgress, downloadProgress) || other.downloadProgress == downloadProgress)&&(identical(other.expandedView, expandedView) || other.expandedView == expandedView));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,emailData,showTagList,showMenuOptions,showAllAttachments,markedAsUnread,movedToArchive,movedToTrash,const DeepCollectionEquality().hash(updatedTags),error,const DeepCollectionEquality().hash(userData),token,newNotification,fileDownloading,downloadProgress,expandedView);

@override
String toString() {
  return 'EmailDetailState(isLoading: $isLoading, emailData: $emailData, showTagList: $showTagList, showMenuOptions: $showMenuOptions, showAllAttachments: $showAllAttachments, markedAsUnread: $markedAsUnread, movedToArchive: $movedToArchive, movedToTrash: $movedToTrash, updatedTags: $updatedTags, error: $error, userData: $userData, token: $token, newNotification: $newNotification, fileDownloading: $fileDownloading, downloadProgress: $downloadProgress, expandedView: $expandedView)';
}


}

/// @nodoc
abstract mixin class $EmailDetailStateCopyWith<$Res>  {
  factory $EmailDetailStateCopyWith(EmailDetailState value, $Res Function(EmailDetailState) _then) = _$EmailDetailStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, ViewEmailModel? emailData, bool showTagList, bool showMenuOptions, bool showAllAttachments, bool markedAsUnread, bool movedToArchive, bool movedToTrash, List<EmailRecipientTags> updatedTags, String? error, Map<String, dynamic>? userData, String token, bool newNotification, bool fileDownloading, double downloadProgress, bool expandedView
});




}
/// @nodoc
class _$EmailDetailStateCopyWithImpl<$Res>
    implements $EmailDetailStateCopyWith<$Res> {
  _$EmailDetailStateCopyWithImpl(this._self, this._then);

  final EmailDetailState _self;
  final $Res Function(EmailDetailState) _then;

/// Create a copy of EmailDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? emailData = freezed,Object? showTagList = null,Object? showMenuOptions = null,Object? showAllAttachments = null,Object? markedAsUnread = null,Object? movedToArchive = null,Object? movedToTrash = null,Object? updatedTags = null,Object? error = freezed,Object? userData = freezed,Object? token = null,Object? newNotification = null,Object? fileDownloading = null,Object? downloadProgress = null,Object? expandedView = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,emailData: freezed == emailData ? _self.emailData : emailData // ignore: cast_nullable_to_non_nullable
as ViewEmailModel?,showTagList: null == showTagList ? _self.showTagList : showTagList // ignore: cast_nullable_to_non_nullable
as bool,showMenuOptions: null == showMenuOptions ? _self.showMenuOptions : showMenuOptions // ignore: cast_nullable_to_non_nullable
as bool,showAllAttachments: null == showAllAttachments ? _self.showAllAttachments : showAllAttachments // ignore: cast_nullable_to_non_nullable
as bool,markedAsUnread: null == markedAsUnread ? _self.markedAsUnread : markedAsUnread // ignore: cast_nullable_to_non_nullable
as bool,movedToArchive: null == movedToArchive ? _self.movedToArchive : movedToArchive // ignore: cast_nullable_to_non_nullable
as bool,movedToTrash: null == movedToTrash ? _self.movedToTrash : movedToTrash // ignore: cast_nullable_to_non_nullable
as bool,updatedTags: null == updatedTags ? _self.updatedTags : updatedTags // ignore: cast_nullable_to_non_nullable
as List<EmailRecipientTags>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,userData: freezed == userData ? _self.userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,newNotification: null == newNotification ? _self.newNotification : newNotification // ignore: cast_nullable_to_non_nullable
as bool,fileDownloading: null == fileDownloading ? _self.fileDownloading : fileDownloading // ignore: cast_nullable_to_non_nullable
as bool,downloadProgress: null == downloadProgress ? _self.downloadProgress : downloadProgress // ignore: cast_nullable_to_non_nullable
as double,expandedView: null == expandedView ? _self.expandedView : expandedView // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EmailDetailState].
extension EmailDetailStatePatterns on EmailDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmailDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmailDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmailDetailState value)  $default,){
final _that = this;
switch (_that) {
case _EmailDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmailDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _EmailDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  ViewEmailModel? emailData,  bool showTagList,  bool showMenuOptions,  bool showAllAttachments,  bool markedAsUnread,  bool movedToArchive,  bool movedToTrash,  List<EmailRecipientTags> updatedTags,  String? error,  Map<String, dynamic>? userData,  String token,  bool newNotification,  bool fileDownloading,  double downloadProgress,  bool expandedView)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmailDetailState() when $default != null:
return $default(_that.isLoading,_that.emailData,_that.showTagList,_that.showMenuOptions,_that.showAllAttachments,_that.markedAsUnread,_that.movedToArchive,_that.movedToTrash,_that.updatedTags,_that.error,_that.userData,_that.token,_that.newNotification,_that.fileDownloading,_that.downloadProgress,_that.expandedView);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  ViewEmailModel? emailData,  bool showTagList,  bool showMenuOptions,  bool showAllAttachments,  bool markedAsUnread,  bool movedToArchive,  bool movedToTrash,  List<EmailRecipientTags> updatedTags,  String? error,  Map<String, dynamic>? userData,  String token,  bool newNotification,  bool fileDownloading,  double downloadProgress,  bool expandedView)  $default,) {final _that = this;
switch (_that) {
case _EmailDetailState():
return $default(_that.isLoading,_that.emailData,_that.showTagList,_that.showMenuOptions,_that.showAllAttachments,_that.markedAsUnread,_that.movedToArchive,_that.movedToTrash,_that.updatedTags,_that.error,_that.userData,_that.token,_that.newNotification,_that.fileDownloading,_that.downloadProgress,_that.expandedView);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  ViewEmailModel? emailData,  bool showTagList,  bool showMenuOptions,  bool showAllAttachments,  bool markedAsUnread,  bool movedToArchive,  bool movedToTrash,  List<EmailRecipientTags> updatedTags,  String? error,  Map<String, dynamic>? userData,  String token,  bool newNotification,  bool fileDownloading,  double downloadProgress,  bool expandedView)?  $default,) {final _that = this;
switch (_that) {
case _EmailDetailState() when $default != null:
return $default(_that.isLoading,_that.emailData,_that.showTagList,_that.showMenuOptions,_that.showAllAttachments,_that.markedAsUnread,_that.movedToArchive,_that.movedToTrash,_that.updatedTags,_that.error,_that.userData,_that.token,_that.newNotification,_that.fileDownloading,_that.downloadProgress,_that.expandedView);case _:
  return null;

}
}

}

/// @nodoc


class _EmailDetailState extends EmailDetailState {
  const _EmailDetailState({this.isLoading = false, this.emailData, this.showTagList = false, this.showMenuOptions = false, this.showAllAttachments = false, this.markedAsUnread = false, this.movedToArchive = false, this.movedToTrash = false, final  List<EmailRecipientTags> updatedTags = const [], this.error, final  Map<String, dynamic>? userData, this.token = '', this.newNotification = false, this.fileDownloading = false, this.downloadProgress = 0.0, this.expandedView = false}): _updatedTags = updatedTags,_userData = userData,super._();
  

@override@JsonKey() final  bool isLoading;
@override final  ViewEmailModel? emailData;
@override@JsonKey() final  bool showTagList;
@override@JsonKey() final  bool showMenuOptions;
@override@JsonKey() final  bool showAllAttachments;
@override@JsonKey() final  bool markedAsUnread;
@override@JsonKey() final  bool movedToArchive;
@override@JsonKey() final  bool movedToTrash;
 final  List<EmailRecipientTags> _updatedTags;
@override@JsonKey() List<EmailRecipientTags> get updatedTags {
  if (_updatedTags is EqualUnmodifiableListView) return _updatedTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_updatedTags);
}

@override final  String? error;
 final  Map<String, dynamic>? _userData;
@override Map<String, dynamic>? get userData {
  final value = _userData;
  if (value == null) return null;
  if (_userData is EqualUnmodifiableMapView) return _userData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  String token;
@override@JsonKey() final  bool newNotification;
@override@JsonKey() final  bool fileDownloading;
@override@JsonKey() final  double downloadProgress;
@override@JsonKey() final  bool expandedView;

/// Create a copy of EmailDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmailDetailStateCopyWith<_EmailDetailState> get copyWith => __$EmailDetailStateCopyWithImpl<_EmailDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmailDetailState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.emailData, emailData) || other.emailData == emailData)&&(identical(other.showTagList, showTagList) || other.showTagList == showTagList)&&(identical(other.showMenuOptions, showMenuOptions) || other.showMenuOptions == showMenuOptions)&&(identical(other.showAllAttachments, showAllAttachments) || other.showAllAttachments == showAllAttachments)&&(identical(other.markedAsUnread, markedAsUnread) || other.markedAsUnread == markedAsUnread)&&(identical(other.movedToArchive, movedToArchive) || other.movedToArchive == movedToArchive)&&(identical(other.movedToTrash, movedToTrash) || other.movedToTrash == movedToTrash)&&const DeepCollectionEquality().equals(other._updatedTags, _updatedTags)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._userData, _userData)&&(identical(other.token, token) || other.token == token)&&(identical(other.newNotification, newNotification) || other.newNotification == newNotification)&&(identical(other.fileDownloading, fileDownloading) || other.fileDownloading == fileDownloading)&&(identical(other.downloadProgress, downloadProgress) || other.downloadProgress == downloadProgress)&&(identical(other.expandedView, expandedView) || other.expandedView == expandedView));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,emailData,showTagList,showMenuOptions,showAllAttachments,markedAsUnread,movedToArchive,movedToTrash,const DeepCollectionEquality().hash(_updatedTags),error,const DeepCollectionEquality().hash(_userData),token,newNotification,fileDownloading,downloadProgress,expandedView);

@override
String toString() {
  return 'EmailDetailState(isLoading: $isLoading, emailData: $emailData, showTagList: $showTagList, showMenuOptions: $showMenuOptions, showAllAttachments: $showAllAttachments, markedAsUnread: $markedAsUnread, movedToArchive: $movedToArchive, movedToTrash: $movedToTrash, updatedTags: $updatedTags, error: $error, userData: $userData, token: $token, newNotification: $newNotification, fileDownloading: $fileDownloading, downloadProgress: $downloadProgress, expandedView: $expandedView)';
}


}

/// @nodoc
abstract mixin class _$EmailDetailStateCopyWith<$Res> implements $EmailDetailStateCopyWith<$Res> {
  factory _$EmailDetailStateCopyWith(_EmailDetailState value, $Res Function(_EmailDetailState) _then) = __$EmailDetailStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, ViewEmailModel? emailData, bool showTagList, bool showMenuOptions, bool showAllAttachments, bool markedAsUnread, bool movedToArchive, bool movedToTrash, List<EmailRecipientTags> updatedTags, String? error, Map<String, dynamic>? userData, String token, bool newNotification, bool fileDownloading, double downloadProgress, bool expandedView
});




}
/// @nodoc
class __$EmailDetailStateCopyWithImpl<$Res>
    implements _$EmailDetailStateCopyWith<$Res> {
  __$EmailDetailStateCopyWithImpl(this._self, this._then);

  final _EmailDetailState _self;
  final $Res Function(_EmailDetailState) _then;

/// Create a copy of EmailDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? emailData = freezed,Object? showTagList = null,Object? showMenuOptions = null,Object? showAllAttachments = null,Object? markedAsUnread = null,Object? movedToArchive = null,Object? movedToTrash = null,Object? updatedTags = null,Object? error = freezed,Object? userData = freezed,Object? token = null,Object? newNotification = null,Object? fileDownloading = null,Object? downloadProgress = null,Object? expandedView = null,}) {
  return _then(_EmailDetailState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,emailData: freezed == emailData ? _self.emailData : emailData // ignore: cast_nullable_to_non_nullable
as ViewEmailModel?,showTagList: null == showTagList ? _self.showTagList : showTagList // ignore: cast_nullable_to_non_nullable
as bool,showMenuOptions: null == showMenuOptions ? _self.showMenuOptions : showMenuOptions // ignore: cast_nullable_to_non_nullable
as bool,showAllAttachments: null == showAllAttachments ? _self.showAllAttachments : showAllAttachments // ignore: cast_nullable_to_non_nullable
as bool,markedAsUnread: null == markedAsUnread ? _self.markedAsUnread : markedAsUnread // ignore: cast_nullable_to_non_nullable
as bool,movedToArchive: null == movedToArchive ? _self.movedToArchive : movedToArchive // ignore: cast_nullable_to_non_nullable
as bool,movedToTrash: null == movedToTrash ? _self.movedToTrash : movedToTrash // ignore: cast_nullable_to_non_nullable
as bool,updatedTags: null == updatedTags ? _self._updatedTags : updatedTags // ignore: cast_nullable_to_non_nullable
as List<EmailRecipientTags>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,userData: freezed == userData ? _self._userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,newNotification: null == newNotification ? _self.newNotification : newNotification // ignore: cast_nullable_to_non_nullable
as bool,fileDownloading: null == fileDownloading ? _self.fileDownloading : fileDownloading // ignore: cast_nullable_to_non_nullable
as bool,downloadProgress: null == downloadProgress ? _self.downloadProgress : downloadProgress // ignore: cast_nullable_to_non_nullable
as double,expandedView: null == expandedView ? _self.expandedView : expandedView // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
