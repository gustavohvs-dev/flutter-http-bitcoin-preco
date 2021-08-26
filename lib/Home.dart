import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  //Google Ads
  @override
  void initState() {
    super.initState();
    // Load ads.
    myBanner.load();
  }

  //Classe banner
  final BannerAd myBanner = BannerAd(
    adUnitId: Platform.isAndroid ? "ca-app-pub-3940256099942544/6300978111" : "ca-app-pub-3940256099942544/2934735716",
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );

  //Create interstitial
  InterstitialAd? _interstitialAd;
  int num_of_attempt_load = 0;
  void createInterad(){
    InterstitialAd.load(
      adUnitId: Platform.isAndroid ? "ca-app-pub-3940256099942544/1033173712" : "ca-app-pub-3940256099942544/4411468910",
      request: AdRequest(),
      adLoadCallback:InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad){
            _interstitialAd = ad;
            num_of_attempt_load =0;
          },
          onAdFailedToLoad: (LoadAdError error){
            num_of_attempt_load +1;
            _interstitialAd = null;
            if(num_of_attempt_load<=2){
              createInterad();
            }
          }),
    );
  }

  //Show interstitial
  void showInterad(){
    createInterad();
    if(_interstitialAd == null){
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad){
          print("ad onAdshowedFullscreen");
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad){
          print("ad Disposed");
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError aderror){
          print('$ad OnAdFailed $aderror');
          ad.dispose();
          createInterad();
        }
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  //Comandos do app

  String _precoCompraBRL = "0.00";
  String _precoVendaBRL = "0.00";
  String _precoCompraUSD = "0.00";
  String _precoVendaUSD = "0.00";

  void _atualizar() async{

    String url = "https://blockchain.info/ticker";
    http.Response response = await http.get(url);

    Map<String, dynamic> bitcoinData = json.decode(response.body);

    setState(() {
      _precoCompraBRL = bitcoinData["BRL"]["buy"].toString();
      _precoVendaBRL = bitcoinData["BRL"]["sell"].toString();
      _precoCompraUSD = bitcoinData["USD"]["buy"].toString();
      _precoVendaUSD = bitcoinData["USD"]["sell"].toString();
    });

    showInterad();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("images/bitcoin.png"),
            Padding(
              padding: EdgeInsets.only(top: 30, bottom: 30),
              child: Text(
                "R\$ ${_precoCompraBRL}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 35
                )
              )
            ),
            ElevatedButton(
                onPressed: _atualizar,
                child: Text("Atualizar"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: TextStyle(
                    fontSize: 30,
                  )
                )
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Container()
            ),
            Positioned(child: Container(
              height: 50,
              width: 320,
              child: AdWidget(ad: myBanner)
            ))
          ],
        )
      )
    );
  }
}
