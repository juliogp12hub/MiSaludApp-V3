import '../models/patient/patient_model.dart';

class PatientMockService {
  static Patient getPacienteDemo() {
    return Patient(
      id: "paciente_001",
      nombre: "Julio González",
      email: "julio@example.com",
      telefono: "+502 5555-1234",
      genero: "masculino",
      fechaNacimiento: DateTime(1999, 08, 21),
      fotoUrl: "https://cdn-icons-png.flaticon.com/512/147/147144.png",
      alergias: ["Penicilina"],
      enfermedades: ["Asma"],
      medicamentos: ["Salbutamol"],
    );
  }
}
