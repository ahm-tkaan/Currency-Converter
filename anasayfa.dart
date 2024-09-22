import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();

  final String _apiKey = "1e4eafc04fd40a510928a8e4b522964d"; // Your API key
  final String _baseUrl = "https://api.exchangeratesapi.io/v1/latest?access_key=";

  Map<String, double> _exchangeRates = {};
  String _selectedCurrency = "USD";
  double _result = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDataFromInternet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Currency Converter"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCurrencyConverterRow(),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : Text(
              "${_result.toStringAsFixed(2)} ₺",
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCurrencyList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyConverterRow() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            _buildCurrencyTextField(),
            const SizedBox(width: 12),
            _buildCurrencyDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyTextField() {
    return Expanded(
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Enter amount',
          border: InputBorder.none,
        ),
        onChanged: (String newValue) {
          _calculate();
        },
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    return DropdownButton<String>(
      value: _selectedCurrency,
      icon: const Icon(Icons.arrow_drop_down),
      underline: const SizedBox(),
      items: _exchangeRates.keys.map((String currency) {
        return DropdownMenuItem<String>(
          value: currency,
          child: Text(currency),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          _selectedCurrency = newValue;
          _calculate();
        }
      },
    );
  }

  Widget _buildCurrencyList() {
    return ListView.builder(
      itemCount: _exchangeRates.keys.length,
      itemBuilder: (context, index) {
        String currency = _exchangeRates.keys.toList()[index];
        double rate = _exchangeRates.values.toList()[index];
        return Card(
          child: ListTile(
            title: Text(currency),
            trailing: Text(rate.toStringAsFixed(2)),
          ),
        );
      },
    );
  }

  void _calculate() {
    double? value = double.tryParse(_controller.text);
    double? rate = _exchangeRates[_selectedCurrency];
    if (value != null && rate != null) {
      setState(() {
        _result = value * rate;
      });
    }
  }

  void _fetchDataFromInternet() async {
    await Future.delayed(Duration(seconds: 2));
    Uri uri = Uri.parse(_baseUrl + _apiKey);
    http.Response response = await http.get(uri);

    Map<String, dynamic> parsedResponse = jsonDecode(response.body);
    Map<String, dynamic> rates = parsedResponse["rates"];

    double? baseTRYRate = rates["TRY"];
    if (baseTRYRate != null) {
      for (String currency in rates.keys) {
        double? baseRate = double.tryParse(rates[currency].toString());
        if (baseRate != null) {
          double tryRate = baseTRYRate / baseRate;
          _exchangeRates[currency] = tryRate;
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }
}