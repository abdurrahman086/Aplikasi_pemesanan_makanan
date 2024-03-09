import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:open_whatsapp/open_whatsapp.dart';
import 'package:pesan_makanan/models/menu_models.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import 'package:http/http.dart' as MyHttp;
import 'package:pesan_makanan/providers/cart_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CartProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController nomorMejaController = TextEditingController();
  final String urlMenu =
      'https://script.google.com/macros/s/AKfycbzyZXZHxvQCtgMnle7Dv0xGFOzYUSoRRMg8CZkdWugzJ3RqOM_tEexIswaIDBYUU547/exec';

  Future<List<MenuModel>> getAllData() async {
    List<MenuModel> ListMenu = [];
    var response = await MyHttp.get(Uri.parse(urlMenu));
    List data = json.decode(response.body);

    data.forEach((element) async {
      ListMenu.add(MenuModel.fromJson(element));
    });

    return ListMenu;
  }

  void openDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 280,
              child: Column(
                children: [
                  Text('Nama', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text('Nomer Meja',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: nomorMejaController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Consumer<CartProvider>(builder: (context, value, _) {
                    String strPesanan = "";
                    value.cart.forEach((element) {
                      strPesanan = strPesanan +
                          "\n" +
                          element.name +
                          "(" +
                          element.quantity.toString() +
                          ")";
                    });
                    return ElevatedButton(
                        onPressed: () {
                          String pesanan = "Nama :" +
                              nameController.text +
                              "\nNomer Meja :" +
                              nomorMejaController.text +
                              "pesanan :" +
                              "\n" +
                              strPesanan;
                          FlutterOpenWhatsapp.sendSingleMessage(
                              "628818775060", pesanan);
                          print(pesanan);
                        },
                        child: Text('Pesan Sekarang'));
                  })
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'waroeng cepat saji',
        ),
        elevation: 0,
        backgroundColor: Colors.blueGrey,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openDialog();
        },
        child: Consumer<CartProvider>(
          builder: (context, value, _) {
            return badges.Badge(
              badgeContent: Text(
                (value.total > 0) ? value.total.toString() : "",
                style: TextStyle(color: Colors.white),
              ),
              child: Icon(Icons.shopping_bag),
            );
          },
        ),
      ),
      body: FutureBuilder(
        future: getAllData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasData) {
              // print('ada data');
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  // ignore: unused_local_variable
                  MenuModel menu = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      height: 120,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(menu.image),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  menu.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  menu.description,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 13),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Rp. " + menu.price.toString(),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Provider.of<CartProvider>(context,
                                                    listen: false)
                                                .addRemove(
                                                    menu.name, menu.id, false);
                                          },
                                          icon: Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Consumer<CartProvider>(
                                          builder: (context, value, _) {
                                            var id = value.cart.indexWhere(
                                                (Element) =>
                                                    Element.menuId ==
                                                    snapshot.data![index].id);
                                            return Text(
                                              (id == -1)
                                                  ? "0"
                                                  : value.cart[id].quantity
                                                      .toString(),
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(width: 10),
                                        IconButton(
                                          onPressed: () {
                                            Provider.of<CartProvider>(context,
                                                    listen: false)
                                                .addRemove(
                                                    menu.name, menu.id, true);
                                          },
                                          icon: Icon(
                                            Icons.add_circle,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text('Tidak ada data'),
              );
            }
          }
        },
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     floatingActionButton: FloatingActionButton(
  //       onPressed: () {},
  //       child: Icon(Icons.shopping_bag),
  //     ),
  //     appBar: AppBar(
  //       title: Text(
  //         'waroeng cepat saji',
  //       ),
  //       backgroundColor: Colors.blueGrey,
  //     ),
  //     body: SingleChildScrollView(
  //       child: SafeArea(
  //         child: FutureBuilder(
  //             future: getAllData(),
  //             builder: (context, snapshot) {
  //               if (snapshot.connectionState == ConnectionState.waiting) {
  //                 return Center(child: CircularProgressIndicator());
  //               } else {
  //                 if (snapshot.hasData) {
  //                   return Expanded(
  //                     child: ListView.builder(
  //                         itemCount: snapshot.data!.length,
  //                         itemBuilder: (context, index) {
  //                           return Padding(
  //                             padding: const EdgeInsets.symmetric(vertical: 10),
  //                             child: Container(
  //                               // Menggunakan Container untuk menentukan ukuran
  //                               height:
  //                                   120, // Menentukan tinggi Container secara eksplisit
  //                               child: Row(
  //                                 children: [
  //                                   Padding(
  //                                     padding: const EdgeInsets.all(16),
  //                                     child: Container(
  //                                       width: 90,
  //                                       height: 90,
  //                                       decoration: BoxDecoration(
  //                                         borderRadius:
  //                                             BorderRadius.circular(10),
  //                                         image: DecorationImage(
  //                                           fit: BoxFit.cover,
  //                                           image: NetworkImage(
  //                                             'https://images.pexels.com/photos/1337825/pexels-photo-1337825.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   Expanded(
  //                                     child: Column(
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.start,
  //                                       children: [
  //                                         Text(
  //                                           'Sari Semangka',
  //                                           style: TextStyle(
  //                                               fontSize: 16,
  //                                               fontWeight: FontWeight.bold),
  //                                         ),
  //                                         SizedBox(height: 8),
  //                                         Text(
  //                                           'Deskripsi yang mungkin agak panjang dan mungkin sangat panjang',
  //                                           textAlign: TextAlign.left,
  //                                           style: TextStyle(fontSize: 13),
  //                                         ),
  //                                         Row(
  //                                           mainAxisAlignment:
  //                                               MainAxisAlignment.spaceBetween,
  //                                           children: [
  //                                             Text(
  //                                               'Rp. 12.000',
  //                                               style: TextStyle(
  //                                                   fontSize: 15,
  //                                                   fontWeight:
  //                                                       FontWeight.bold),
  //                                             ),
  //                                             Row(
  //                                               children: [
  //                                                 IconButton(
  //                                                   onPressed: () {},
  //                                                   icon: Icon(
  //                                                     Icons.remove_circle,
  //                                                     color: Colors.red,
  //                                                   ),
  //                                                 ),
  //                                                 SizedBox(width: 10),
  //                                                 Text(
  //                                                   '0',
  //                                                   style: TextStyle(
  //                                                       fontSize: 15,
  //                                                       fontWeight:
  //                                                           FontWeight.bold),
  //                                                 ),
  //                                                 SizedBox(width: 10),
  //                                                 IconButton(
  //                                                   onPressed: () {},
  //                                                   icon: Icon(
  //                                                     Icons.add_circle,
  //                                                     color: Colors.green,
  //                                                   ),
  //                                                 ),
  //                                               ],
  //                                             )
  //                                           ],
  //                                         )
  //                                       ],
  //                                     ),
  //                                   )
  //                                 ],
  //                               ),
  //                             ),
  //                           );
  //                         }),
  //                   );
  //                 } else {
  //                   return Center(
  //                     child: Text('Tidak ada data'),
  //                   );
  //                 }

  // return Padding(
  //   padding: const EdgeInsets.symmetric(vertical: 10),
  //   child: Column(children: [
  //     Row(
  //         // crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.all(16),
  //             child: Container(
  //               width: 90,
  //               height: 90,
  //               decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(10),
  //                   image: DecorationImage(
  //                     fit: BoxFit.cover,
  //                     image: NetworkImage(
  //                         'https://images.pexels.com/photos/1337825/pexels-photo-1337825.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
  //                   )),
  //             ),
  //           )
  //         ]),
  //     Expanded(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Sari Semangka',
  //             style: TextStyle(
  //                 fontSize: 16, fontWeight: FontWeight.bold),
  //           ),
  //           SizedBox(
  //             height: 8,
  //           ),
  //           Text(
  //             'Deskripsi yang mungkin agak panjang dan mungkin sangat panjang',
  //             textAlign: TextAlign.left,
  //             style: TextStyle(
  //               fontSize: 13,
  //             ),
  //           ),
  //           // SizedBox(
  //           //   height: 8,
  //           // ),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 'Rp. 12.000',
  //                 style: TextStyle(
  //                     fontSize: 15,
  //                     fontWeight: FontWeight.bold),
  //               ),
  //               Row(
  //                 children: [
  //                   IconButton(
  //                       onPressed: () {},
  //                       icon: Icon(
  //                         Icons.remove_circle,
  //                         color: Colors.red,
  //                       )),
  //                   SizedBox(
  //                     width: 10,
  //                   ),
  //                   Text(
  //                     '0',
  //                     style: TextStyle(
  //                         fontSize: 15,
  //                         fontWeight: FontWeight.bold),
  //                   ),
  //                   SizedBox(
  //                     width: 10,
  //                   ),
  //                   IconButton(
  //                     onPressed: () {},
  //                     icon: Icon(
  //                       Icons.add_circle,
  //                       color: Colors.green,
  //                     ),
  //                   ),
  //                 ],
  //               )
  //             ],
  //           )
  //         ],
  //       ),
  //     )
  //   ]),
  // );
//                 }
//               }),
//         ),
//       ),
//     );
//   }
}
