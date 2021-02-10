class oneShot {
  final int id;
  final String username;
  final double pulse;
  final double spo2;
  final double temp;
  final double pres;
  final String timestamp;


  oneShot({this.id, this.username, this.pulse, this.spo2, this.temp, this.pres, this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'pulse': pulse,
      'spo2': spo2,
      'temp': temp,
      'pres': pres,
      'timestamp': timestamp,
    };
  }

  factory oneShot.fromJson(Map<String, dynamic> json) {
    return oneShot(
      id: json['id'],
      username: json['username'],
      pulse: json['pulse'],
      spo2: json['spo2'],
      temp: json['temp'],
      pres: json['pres'],
      timestamp: json['timestamp'],
    );
  }

  @override
  String toString() {
    return 'oneShot{id: $id, username: $username, pulse: $pulse, spo2: $spo2, temp: $temp, pres: $pres, timestamp: $timestamp,}';
  }
}

