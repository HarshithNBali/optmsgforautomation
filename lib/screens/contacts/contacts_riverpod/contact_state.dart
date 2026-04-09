import '../../../model/contact_list_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact_state.freezed.dart'; // Make sure the filename matches

@freezed
abstract class ContactState with _$ContactState {
  const factory ContactState({
    @Default(true) bool isLoading,
    @Default(false) bool isInProcess,
    @Default(false) bool isRefresh,
    @Default(false) bool readingPaneEnabled,
    @Default(false) bool clearSelectedContact,
    @Default(false) bool isSearch,
    @Default([]) List<Contacts> allContacts,
    @Default([]) List<Contacts> filteredContacts,
    Contacts? selectedContact,
    @Default('') String searchText,
    Map<String, dynamic>? userData,
    // Filter state
    @Default('all') String contactTypeFilter,
    @Default(false) bool showFilter,
    // Multi-select state
    @Default([]) List<int> selectedContactIds,
    @Default(true) bool longPressFlag,
    @Default(false) bool allContactsFlag,
    @Default(false) bool showCheckboxes,
    @Default(-1) int lastClickedIndex,
  }) = _ContactState;

  const ContactState._();
  bool get hasContacts => filteredContacts.isNotEmpty;
  bool get hasActiveFilter => contactTypeFilter != 'all';
  bool get hasMultiSelection => selectedContactIds.isNotEmpty;
  int get selectedCount => selectedContactIds.length;
  bool get isAllSelected =>
      selectedContactIds.length == filteredContacts.length &&
      filteredContacts.isNotEmpty;
}
