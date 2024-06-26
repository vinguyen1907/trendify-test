import 'package:ecommerce_app/models/shipping_address.dart';
import 'package:ecommerce_app/repositories/address_repository.dart';
import 'package:ecommerce_app/repositories/interfaces/interfaces.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

part 'addresses_event.dart';
part 'addresses_state.dart';

class AddressesBloc extends Bloc<AddressesEvent, AddressesState> {
  final IAddressRepository _addressRepository = GetIt.I.get();

  AddressesBloc() : super(AddressesInitial()) {
    on<LoadAddresses>(_onLoadAddresses);
    on<DeleteAddress>(_onDeleteAddress);
  }
  _onLoadAddresses(event, emit) async {
    emit(AddressesLoading());
    try {
      final addresses = await _addressRepository.fetchShippingAddresses();
      emit(AddressesLoaded(
          addresses: addresses, lastTimeChanged: DateTime.now()));
    } catch (e) {
      emit(AddressesError(e.toString()));
    }
  }

  _onDeleteAddress(DeleteAddress event, emit) async {
    try {
      if (state is AddressesLoaded) {
        final addresses = (state as AddressesLoaded).addresses;
        addresses.removeWhere((element) => element.id == event.addressId);
        emit(AddressesLoaded(
            addresses: addresses, lastTimeChanged: DateTime.now()));
        await AddressRepository().deleteAddress(addressId: event.addressId);
      }
    } catch (e) {
      print("Delete address error: $e");
    }
  }
}
