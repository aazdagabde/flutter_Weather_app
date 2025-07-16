import 'package:flutter/material.dart';

class WeatherUtils {
  // Cette méthode retourne une description textuelle
  static String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Ciel dégagé';
      case 1:
      case 2:
      case 3:
        return 'Partiellement nuageux';
      case 45:
      case 48:
        return 'Brouillard';
      case 51:
      case 53:
      case 55:
        return 'Bruine';
      case 61:
      case 63:
      case 65:
        return 'Pluie';
      case 66:
      case 67:
        return 'Pluie verglaçante';
      case 71:
      case 73:
      case 75:
        return 'Chute de neige';
      case 80:
      case 81:
      case 82:
        return 'Averses de pluie';
      case 95:
      case 96:
      case 99:
        return 'Orages';
      default:
        return 'Inconnu';
    }
  }

  // Cette méthode retourne une icône correspondante
  static IconData getWeatherIcon(int code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny; // Soleil
      case 1:
      case 2:
      case 3:
        return Icons.cloud; // Nuage
      case 45:
      case 48:
        return Icons.dehaze; // Brouillard/Brume
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return Icons.grain; // Gouttes de pluie
      case 66:
      case 67:
        return Icons.ac_unit; // Flocon (pour verglas)
      case 71:
      case 73:
      case 75:
        return Icons.ac_unit; // Flocon de neige
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm; // Orage
      default:
        return Icons.help_outline;
    }
  }
}
