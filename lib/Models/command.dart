import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? _asDateTime(dynamic value) {
	if (value is Timestamp) return value.toDate();
	if (value is DateTime) return value;
	if (value is String) return DateTime.tryParse(value);
	return null;
}

double _asDouble(dynamic value) {
	if (value is num) return value.toDouble();
	return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _asInt(dynamic value) {
	if (value is num) return value.toInt();
	return int.tryParse(value?.toString() ?? '') ?? 0;
}

Map<String, dynamic>? _asMap(dynamic value) {
	if (value is Map<String, dynamic>) return value;
	if (value is Map) {
		return value.map((key, value) => MapEntry(key.toString(), value));
	}
	return null;
}

String _asString(dynamic value) => value?.toString() ?? '';

class CommandAddressModel {
	final String id;
	final String street;
	final String city;
	final String postalCode;
	final String country;
	final bool isDefault;

	const CommandAddressModel({
		this.id = '',
		this.street = '',
		this.city = '',
		this.postalCode = '',
		this.country = '',
		this.isDefault = false,
	});

	factory CommandAddressModel.fromMap(Map<String, dynamic> map) {
		return CommandAddressModel(
			id: _asString(map['id']),
			street: _asString(map['street']),
			city: _asString(map['city']),
			postalCode: _asString(map['postalCode']),
			country: _asString(map['country']),
			isDefault: map['isDefault'] == true,
		);
	}

	Map<String, dynamic> toMap() {
		return {
			'id': id,
			'street': street,
			'city': city,
			'postalCode': postalCode,
			'country': country,
			'isDefault': isDefault,
		};
	}

	CommandAddressModel copyWith({
		String? id,
		String? street,
		String? city,
		String? postalCode,
		String? country,
		bool? isDefault,
	}) {
		return CommandAddressModel(
			id: id ?? this.id,
			street: street ?? this.street,
			city: city ?? this.city,
			postalCode: postalCode ?? this.postalCode,
			country: country ?? this.country,
			isDefault: isDefault ?? this.isDefault,
		);
	}
}

class CommandItemModel {
	final String cartId;
	final String productId;
	final String title;
	final String author;
	final String image;
	final int quantity;
	final double unitPrice;
	final double lineTotal;

	const CommandItemModel({
		this.cartId = '',
		this.productId = '',
		this.title = '',
		this.author = '',
		this.image = '',
		this.quantity = 0,
		this.unitPrice = 0,
		this.lineTotal = 0,
	});

	factory CommandItemModel.fromMap(Map<String, dynamic> map) {
		return CommandItemModel(
			cartId: _asString(map['cartId']),
			productId: _asString(map['productId']),
			title: _asString(map['title']),
			author: _asString(map['author']),
			image: _asString(map['image']),
			quantity: _asInt(map['quantity']),
			unitPrice: _asDouble(map['unitPrice']),
			lineTotal: _asDouble(map['lineTotal']),
		);
	}

	Map<String, dynamic> toMap() {
		return {
			'cartId': cartId,
			'productId': productId,
			'title': title,
			'author': author,
			'image': image,
			'quantity': quantity,
			'unitPrice': unitPrice,
			'lineTotal': lineTotal,
		};
	}

	CommandItemModel copyWith({
		String? cartId,
		String? productId,
		String? title,
		String? author,
		String? image,
		int? quantity,
		double? unitPrice,
		double? lineTotal,
	}) {
		return CommandItemModel(
			cartId: cartId ?? this.cartId,
			productId: productId ?? this.productId,
			title: title ?? this.title,
			author: author ?? this.author,
			image: image ?? this.image,
			quantity: quantity ?? this.quantity,
			unitPrice: unitPrice ?? this.unitPrice,
			lineTotal: lineTotal ?? this.lineTotal,
		);
	}
}

class CommandModel {
	final String id;
	final String userId;
	final String status;
	final String paymentMethod;
	final DateTime? createdAt;
	final DateTime? paidAt;
	final double subtotal;
	final double delivery;
	final double total;
	final List<CommandItemModel> items;
	final CommandAddressModel? address;

	const CommandModel({
		this.id = '',
		required this.userId,
		required this.status,
		required this.paymentMethod,
		this.createdAt,
		this.paidAt,
		required this.subtotal,
		required this.delivery,
		required this.total,
		required this.items,
		this.address,
	});

	factory CommandModel.fromFirestore(DocumentSnapshot doc) {
		final data = doc.data() as Map<String, dynamic>;
		return CommandModel.fromMap({
			...data,
			'id': doc.id,
		});
	}

	factory CommandModel.fromMap(Map<String, dynamic> map) {
		final rawItems = map['items'];
		final rawAddress = _asMap(map['address']);

		return CommandModel(
			id: _asString(map['id']),
			userId: _asString(map['userId']),
			status: _asString(map['status']),
			paymentMethod: _asString(map['paymentMethod']),
			createdAt: _asDateTime(map['createdAt']),
			paidAt: _asDateTime(map['paidAt']),
			subtotal: _asDouble(map['subtotal']),
			delivery: _asDouble(map['delivery']),
			total: _asDouble(map['total']),
			items: rawItems is List
					? rawItems
							.whereType<Map>()
							.map(
								(item) => CommandItemModel.fromMap(
									item.map((key, value) => MapEntry(key.toString(), value)),
								),
							)
							.toList()
					: <CommandItemModel>[],
			address: rawAddress == null ? null : CommandAddressModel.fromMap(rawAddress),
		);
	}

	Map<String, dynamic> toMap() {
		return {
			'id': id,
			'userId': userId,
			'status': status,
			'paymentMethod': paymentMethod,
			'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
			'paidAt': paidAt == null ? null : Timestamp.fromDate(paidAt!),
			'subtotal': subtotal,
			'delivery': delivery,
			'total': total,
			'items': items.map((item) => item.toMap()).toList(),
			'address': address?.toMap(),
		};
	}

	CommandModel copyWith({
		String? id,
		String? userId,
		String? status,
		String? paymentMethod,
		DateTime? createdAt,
		DateTime? paidAt,
		double? subtotal,
		double? delivery,
		double? total,
		List<CommandItemModel>? items,
		CommandAddressModel? address,
	}) {
		return CommandModel(
			id: id ?? this.id,
			userId: userId ?? this.userId,
			status: status ?? this.status,
			paymentMethod: paymentMethod ?? this.paymentMethod,
			createdAt: createdAt ?? this.createdAt,
			paidAt: paidAt ?? this.paidAt,
			subtotal: subtotal ?? this.subtotal,
			delivery: delivery ?? this.delivery,
			total: total ?? this.total,
			items: items ?? this.items,
			address: address ?? this.address,
		);
	}
}
