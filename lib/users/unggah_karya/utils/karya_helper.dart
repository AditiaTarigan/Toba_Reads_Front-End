// File: utils/karya_helper.dart
import 'dart:io';
import 'package:flutter/material.dart';

class KaryaHelper {
  // Helper function untuk akses properti dengan aman
  static dynamic getProperty(dynamic obj, String property) {
    if (obj is Map) {
      return obj[property];
    } else {
      // Coba akses via reflection sederhana
      try {
        return _getPropertyFromObject(obj, property);
      } catch (e) {
        return null;
      }
    }
  }

  static dynamic _getPropertyFromObject(dynamic obj, String property) {
    // Try common property access patterns
    switch (property) {
      case 'judul':
        return obj.judul ?? obj.title ?? obj.nama;
      case 'sinopsis': // <-- TAMBAH INI
        return obj.sinopsis ?? obj.synopsis ?? obj.summary;
      case 'isi':
        return obj.isi ?? obj.content ?? obj.deskripsi;
      case 'status':
        return obj.status ?? obj.state ?? obj.approvalStatus;
      case 'created_at':
        return obj.createdAt ?? obj.createdDate ?? obj.tanggalDibuat;
      case 'file_lampiran':
        return obj.fileLampiran ?? obj.fileAttachment ?? obj.attachment;
      case 'gambar_url':
        return obj.gambarUrl ?? obj.imageUrl ?? obj.fotoUrl;
      case 'id':
        return obj.id ?? obj.idKarya ?? obj.karyaId;
      case 'id_karya':
        return obj.idKarya ?? obj.id ?? obj.karyaId;
      default:
        return null;
    }
  }

  // Tambah validator untuk sinopsis
  static String? validateSinopsis(String? value) {
    if (value == null || value.isEmpty) {
      return 'Sinopsis tidak boleh kosong';
    }
    return null;
  }

  // Get image URL
  static String? getImageUrl(dynamic karya) {
    String? gambarUrl = getProperty(karya, 'gambar_url');
    if (gambarUrl == null) {
      final fileLampiran = getProperty(karya, 'file_lampiran');
      if (fileLampiran != null) {
        gambarUrl = 'http://10.167.29.12:8000/storage/$fileLampiran';
      }
    }
    return gambarUrl;
  }

  // Format tanggal
  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  // Parse tanggal dari dynamic
  static DateTime parseDate(dynamic date) {
    if (date is String) {
      return DateTime.tryParse(date) ?? DateTime.now();
    } else if (date is DateTime) {
      return date;
    } else {
      return DateTime.now();
    }
  }

  // Get warna berdasarkan status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diterima':
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  // Get warna background berdasarkan status
  static Color getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'diterima':
      case 'approved':
        return Colors.green.withOpacity(0.1);
      case 'pending':
        return Colors.orange.withOpacity(0.1);
      default:
        return Colors.red.withOpacity(0.1);
    }
  }

  // Validate form
  static String? validateJudul(String? value) {
    if (value == null || value.isEmpty) {
      return 'Judul tidak boleh kosong';
    }
    return null;
  }

  static String? validateIsi(String? value) {
    if (value == null || value.isEmpty) {
      return 'Isi tidak boleh kosong';
    }
    return null;
  }
}
