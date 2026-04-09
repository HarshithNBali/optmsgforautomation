import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../model/contact_email_details.dart';
import '../../../model/contact_list_model.dart';

part 'view_contact_state.freezed.dart';

@freezed
abstract class ViewContactState with _$ViewContactState {
  const factory ViewContactState({
    @Default(false) bool isSubmitting,
    @Default(false) bool loadingContactDetails,
    @Default(false) bool readingPaneEnabled,
    @Default('') String token,
    @Default([]) List<Contact> emails,
    Contacts? contact,
  }) = _ViewContactState;
}
