# Dokumentasi Alur Kerja Aplikasi - Sistem Approval Server-Driven

## 🎯 Konsep Utama: 100% Server-Driven Architecture

Aplikasi ini menggunakan arsitektur **Server-Driven UI** dimana:
- **Backend mengontrol semua struktur dan konfigurasi**
- **Frontend hanya render berdasarkan data dari server**
- **Tidak ada hardcoded routes atau business logic di frontend**
- **Menambah master baru tidak perlu update kode frontend**

---

## 📱 Alur Kerja Lengkap Aplikasi

### 1. **Startup & Authentication Flow**

```
App Start
    ↓
AuthGate (main.dart)
    ↓
Cek Token di StorageHelper
    ↓
    ├─ Token ada & valid → DashboardPage
    └─ Token tidak ada/invalid → LoginPage
```

**Komponen:**
- `AuthGate`: Widget yang cek authentication saat app start
- `AuthService`: Service untuk handle login/logout
- `StorageHelper`: Helper untuk simpan/load token dari SharedPreferences

---

### 2. **Login Flow**

```
LoginPage
    ↓
User input email & password
    ↓
POST /api/login
    ↓
Backend return: { token, user_data }
    ↓
Simpan token ke StorageHelper
    ↓
Simpan user data ke StorageHelper
    ↓
Navigate ke DashboardPage
```

**Detail:**
- Token disimpan sebagai Bearer token untuk semua API request berikutnya
- User data disimpan untuk ditampilkan di dashboard

---

### 3. **Dashboard & Menu Loading (Server-Driven)**

```
DashboardPage
    ↓
GET /api/menu (dengan Authorization token)
    ↓
Response dari Server:
{
  "success": true,
  "data": {
    "menus": [
      {
        "id": 1,
        "label": "Approval Lembur",
        "icon": "access_time",
        "menu_link": "/lembur/approval",
        "index": 1
      },
      {
        "id": 2,
        "label": "Approval Cuti",
        "icon": "rule",
        "menu_link": "/cuti/approve",
        "index": 2
      },
      ...
    ],
    "user": { ... }
  }
}
    ↓
Parse menjadi List<MenuModel>
    ↓
Tampilkan menu sebagai GridView
```

**Keuntungan Server-Driven:**
- ✅ Backend menentukan menu apa yang ditampilkan berdasarkan role user
- ✅ Menu bisa berbeda untuk Supervisor vs Manager
- ✅ Menambah menu baru cukup update database, tidak perlu update app
- ✅ Menu diurutkan berdasarkan `index` dari server

---

### 4. **Dynamic Routing System**

Ketika user klik menu di dashboard:

```
User klik menu dengan menuLink: "/lembur/approval"
    ↓
_navigateToMenu() dipanggil
    ↓
RouteManager.normalizeRoute("/lembur/approval")
    → Returns: "/lembur/approval" (normalized)
    ↓
AppRoutes.hasRoute("/lembur/approval")
    ↓
DynamicRouteResolver.resolveRoute("/lembur/approval")
    ↓
Parse menuLink:
    - parts[0] = "lembur" (masterName)
    - parts[1] = "approval" (action)
    ↓
Deteksi action = "approval" → Build Approval Route
    ↓
_buildApprovalRoute("lembur")
    ↓
Return WidgetBuilder untuk GenericApprovalPage dengan:
    - apiUrl: "/api/lembur"
    - masterName: "lembur"
    ↓
Navigator.pushNamed(context, "/lembur/approval")
    ↓
onGenerateRoute di main.dart memanggil DynamicRouteResolver
    ↓
GenericApprovalPage ditampilkan
```

**Komponen Routing:**

1. **DynamicRouteResolver** (`lib/routes/dynamic_route_resolver.dart`)
   - Parse `menuLink` dari server
   - Resolve menjadi WidgetBuilder secara dinamis
   - Tidak ada hardcoded routes

2. **AppRoutes** (`lib/routes/app_routes.dart`)
   - Routes map kosong (100% server-driven)
   - `getRoute()` dan `hasRoute()` menggunakan `DynamicRouteResolver`

3. **main.dart**
   - `onGenerateRoute`: Handler untuk resolve route secara dinamis
   - Jika route tidak ditemukan, gunakan `DynamicRouteResolver`

---

### 5. **GenericApprovalPage - Dynamic Approval System**

Setelah user masuk ke approval page:

```
GenericApprovalPage initState()
    ↓
Create DynamicApprovalController dengan:
    - apiUrl: "/api/lembur" (dari DynamicRouteResolver)
    - masterName: "lembur"
    ↓
_loadItems() dipanggil
    ↓
DynamicApprovalController.loadItems()
    ↓
GET /api/lembur
    ↓
Headers yang dikirim:
    - Authorization: Bearer {token}
    - X-Correlation-Id: {UUID per request}
    - X-Device-Id: {device ID persisten}
    ↓
Response dari Server:
{
  "success": true,
  "config": {
    "page_title": "Approval Lembur",
    "mapping": {
      "title": "tanggal",
      "subtitle": "keterangan",
      "date": "created_at",
      "status": "status"
    }
  },
  "data": [
    {
      "id": 1,
      "tanggal": "2024-01-15",
      "keterangan": "Lembur proyek X",
      "created_at": "2024-01-10 10:00:00",
      "status": "PENDING_SPV",
      ...
    },
    ...
  ]
}
    ↓
Parse Config:
    - _pageTitle = "Approval Lembur"
    - _mapping = {
        "title": "tanggal",
        "subtitle": "keterangan",
        ...
      }
    ↓
Mapping Data menggunakan _mapping:
    - data[0]["tanggal"] → ApprovalItem.title
    - data[0]["keterangan"] → ApprovalItem.subtitle
    - data[0]["created_at"] → ApprovalItem.date
    - data[0]["status"] → ApprovalItem.status
    ↓
Return List<ApprovalItem>
    ↓
Display di ListView dengan ApprovalCard
```

**Keuntungan Dynamic Mapping:**
- ✅ Backend menentukan field mana yang jadi title, subtitle, dll
- ✅ Struktur data bisa berbeda per master
- ✅ Menambah master baru tidak perlu update frontend
- ✅ Field mapping bisa diubah dari backend tanpa update app

---

### 6. **Approval Action Flow**

Ketika user klik tombol Approve/Reject:

#### **Approve Flow:**

```
User klik tombol Approve di ApprovalCard
    ↓
_handleApprove(item) dipanggil
    ↓
Cek _isSubmitting (prevent double submit)
    ↓
Set _isSubmitting = true (disable button)
    ↓
DynamicApprovalController.approve(item.id)
    ↓
Construct URL: {apiUrl}/{id}/approve
    Contoh: "/api/lembur/5/approve"
    ↓
POST /api/lembur/5/approve
Headers:
    - Authorization: Bearer {token}
    - X-Correlation-Id: {new UUID}
    - X-Device-Id: {device ID}
Body:
    { "action": "approve" }
    ↓
Retry dengan exponential backoff jika network error:
    - Attempt 1: delay 700ms
    - Attempt 2: delay 1400ms
    - Attempt 3: delay 2800ms
    - Tidak retry pada 4xx errors
    ↓
Backend membaca token → determine role user
    ↓
Backend determine level approval:
    - Jika user = SUPERVISOR → approveBySupervisor()
    - Jika user = MANAGER → approveByManager()
    - Future: bisa ada level lain
    ↓
Response dari Backend:
    {
      "success": true,
      "message": "Approved successfully"
    }
    ↓
Handle Response:
    ├─ Status 200/201 → Success → Reload items
    ├─ Status 409 → Conflict → Show "Data sudah diproses, silakan refresh" → Reload items
    └─ Status lain → Error → Show error message
    ↓
Set _isSubmitting = false (enable button lagi)
```

#### **Reject Flow:**

```
User klik tombol Reject
    ↓
Show Dialog untuk input reject reason
    ↓
User input alasan reject
    ↓
_handleReject(item, rejectReason)
    ↓
POST /api/lembur/5/reject
Body:
    {
      "action": "reject",
      "reject_reason": "Alasan reject dari user"
    }
    ↓
Backend handle reject sesuai role
    ↓
Response & handle sama seperti approve
```

**Keuntungan Generic Endpoint:**
- ✅ Frontend hanya tahu: approve/reject dengan ID
- ✅ Backend yang menentukan level approval berdasarkan token
- ✅ Menambah level approval baru tidak perlu update frontend
- ✅ Satu endpoint untuk semua level: `/api/{master}/{id}/approve`

---

### 7. **PDF Viewer Flow**

Ketika user klik tombol Detail (info icon):

```
User klik tombol Detail
    ↓
_handleDetail(item)
    ↓
Construct PDF URL: ApiConfig.exportMasterById("lembur", item.id)
    → "/api/export/lembur/5"
    ↓
Navigator.push ke PdfViewerPage
    ↓
PdfViewerPage membuka URL dengan flutter_cached_pdfview
    ↓
GET /api/export/lembur/5
    ↓
Backend generate PDF detail untuk lembur ID 5
    ↓
Return PDF file
    ↓
Display PDF di viewer dengan:
    - Loading indicator saat download
    - Error handling jika gagal
    - Swipe gesture untuk navigate pages
```

---

## 🔄 Fitur Dinamis yang Membuat Aplikasi Fleksibel

### 1. **Server-Driven Menu System**
```
Backend Database:
┌─────────────────────────────────┐
│ Menu Table                      │
├────┬──────────────┬─────────────┤
│ ID │ menu_link    │ role_access │
├────┼──────────────┼─────────────┤
│ 1  │ /lembur/...  │ SUPERVISOR  │
│ 2  │ /cuti/...    │ MANAGER     │
│ 3  │ /po/...      │ ALL         │
│ 4  │ /absensi/... │ SUPERVISOR  │ ← Master baru!
└────┴──────────────┴─────────────┘
         ↓
    GET /api/menu
         ↓
Frontend auto-render menu baru
         ↓
Tidak perlu update app untuk master baru!
```

### 2. **Dynamic Route Resolution**
```
menuLink dari server → DynamicRouteResolver → Widget

/lembur/approval → GenericApprovalPage(apiUrl: "/api/lembur", masterName: "lembur")
/cuti/approve    → GenericApprovalPage(apiUrl: "/api/cuti", masterName: "cuti")
/po/approval     → GenericApprovalPage(apiUrl: "/api/po", masterName: "po")
/absensi/approve → GenericApprovalPage(apiUrl: "/api/absensi", masterName: "absensi")
```

**Tidak ada hardcoded routes di AppRoutes!**

### 3. **Dynamic Data Mapping**
```
Backend Config:
{
  "mapping": {
    "title": "tanggal",      // Field "tanggal" → ApprovalItem.title
    "subtitle": "keterangan", // Field "keterangan" → ApprovalItem.subtitle
    "date": "created_at",     // Field "created_at" → ApprovalItem.date
    "status": "status"        // Field "status" → ApprovalItem.status
  }
}

Backend bisa mengubah mapping tanpa update app:
{
  "mapping": {
    "title": "nama_barang",     // Changed!
    "subtitle": "total_harga",  // Changed!
    ...
  }
}
```

### 4. **Dynamic Approval Level**
```
Frontend:
POST /api/lembur/5/approve
Headers: Authorization: Bearer {token}

Backend:
1. Decode token → get user role
2. Check role:
   - SUPERVISOR → approveBySupervisor(5)
   - MANAGER → approveByManager(5)
   - DIRECTOR → approveByDirector(5) ← Level baru, frontend tidak perlu tahu!
3. Return response

Frontend hanya tahu: approve dengan ID 5
Backend yang handle level approval
```

---

## 📊 Diagram Alur Komplit

```
┌─────────────────────────────────────────────────────────────┐
│                        APP START                             │
└──────────────────────┬──────────────────────────────────────┘
                       ↓
            ┌──────────────────────┐
            │   AuthGate           │
            │   - Cek Token        │
            └──────┬───────────────┘
                   ↓
        ┌──────────┴──────────┐
        │                     │
   Token Ada            Token Tidak Ada
        │                     │
        ↓                     ↓
┌───────────────┐    ┌──────────────┐
│ DashboardPage │    │  LoginPage   │
└───────┬───────┘    └──────┬───────┘
        │                   │
        │              POST /api/login
        │                   │
        │              Save Token
        │                   │
        └───────────┬───────┘
                    ↓
        ┌───────────────────────┐
        │   DashboardPage       │
        │   GET /api/menu       │
        └───────────┬───────────┘
                    ↓
        ┌───────────────────────┐
        │   Server Response:    │
        │   List<MenuModel>     │
        │   - menu_link         │
        │   - label, icon       │
        └───────────┬───────────┘
                    ↓
        ┌───────────────────────┐
        │   User Klik Menu      │
        │   menuLink:           │
        │   "/lembur/approval"  │
        └───────────┬───────────┘
                    ↓
        ┌──────────────────────────────────┐
        │   DynamicRouteResolver           │
        │   - Parse menuLink               │
        │   - Extract masterName           │
        │   - Build GenericApprovalPage    │
        └───────────┬──────────────────────┘
                    ↓
        ┌──────────────────────────────────┐
        │   GenericApprovalPage            │
        │   - apiUrl: "/api/lembur"        │
        │   - masterName: "lembur"         │
        └───────────┬──────────────────────┘
                    ↓
        ┌──────────────────────────────────┐
        │   DynamicApprovalController      │
        │   GET /api/lembur                │
        └───────────┬──────────────────────┘
                    ↓
        ┌──────────────────────────────────┐
        │   Server Response:               │
        │   {                              │
        │     "config": {                  │
        │       "page_title": "...",       │
        │       "mapping": {...}           │
        │     },                           │
        │     "data": [...]                │
        │   }                              │
        └───────────┬──────────────────────┘
                    ↓
        ┌──────────────────────────────────┐
        │   Map Data → List<ApprovalItem>  │
        │   Menggunakan mapping dari config│
        └───────────┬──────────────────────┘
                    ↓
        ┌──────────────────────────────────┐
        │   Display ApprovalCard untuk     │
        │   setiap ApprovalItem            │
        └───────────┬──────────────────────┘
                    ↓
        ┌──────────────────────────────────┐
        │   User Action:                   │
        │   - Approve                      │
        │   - Reject                       │
        │   - Detail (PDF)                 │
        └───────────┬──────────────────────┘
                    ↓
        ┌──────────────────────────────────┐
        │   POST /api/{master}/{id}/       │
        │   approve atau reject            │
        │   Backend determine level        │
        │   berdasarkan token              │
        └──────────────────────────────────┘
```

---

## 🎨 Arsitektur Komponen

### **Layer Architecture:**

```
┌─────────────────────────────────────────┐
│         UI Layer (Pages)                │
│  - GenericApprovalPage                  │
│  - DashboardPage                        │
│  - LoginPage                            │
│  - PdfViewerPage                        │
└──────────────┬──────────────────────────┘
               │
┌──────────────┴──────────────────────────┐
│      Controller Layer                   │
│  - DynamicApprovalController            │
│  - ApprovalController (interface)       │
└──────────────┬──────────────────────────┘
               │
┌──────────────┴──────────────────────────┐
│      Service Layer                      │
│  - MenuService                          │
│  - AuthService                          │
└──────────────┬──────────────────────────┘
               │
┌──────────────┴──────────────────────────┐
│      Model Layer                        │
│  - ApprovalItem                         │
│  - MenuModel                            │
│  - AuthUserModel                        │
└──────────────┬──────────────────────────┘
               │
┌──────────────┴──────────────────────────┐
│      Utility Layer                      │
│  - StorageHelper                        │
│  - RouteManager                         │
│  - DateHelper                           │
└──────────────┬──────────────────────────┘
               │
┌──────────────┴──────────────────────────┐
│      Routing Layer                      │
│  - DynamicRouteResolver                 │
│  - AppRoutes                            │
└──────────────┬──────────────────────────┘
               │
┌──────────────┴──────────────────────────┐
│      API Layer                          │
│  - ApiConfig                            │
│  - HTTP Client (with retry/backoff)     │
└─────────────────────────────────────────┘
```

---

## 🔑 Poin-Poin Penting Sistem Dinamis

### 1. **Tidak Ada Hardcoded Routes**
- Semua route di-resolve dari `menuLink` server
- Menambah route baru = update database, bukan update code

### 2. **Tidak Ada Hardcoded Field Mapping**
- Field mapping datang dari config API response
- Struktur data bisa berbeda per master

### 3. **Tidak Ada Hardcoded Approval Level**
- Backend determine level berdasarkan token
- Frontend tidak perlu tahu user adalah supervisor/manager

### 4. **Tidak Ada Hardcoded Master**
- Menambah master baru cukup:
  1. Backend: Tambah route + controller
  2. Database: Tambah menu dengan menuLink baru
  3. Frontend: Auto-work (tidak perlu update code!)

### 5. **Tidak Ada Hardcoded Business Logic**
- Filter data (pending supervisor/manager) di backend
- Frontend hanya render data yang dikirim backend

---

## 📝 Contoh: Menambah Master Baru "Absensi"

### **Backend (Laravel):**
```php
// 1. Tambah route
Route::prefix('absensi')->group(function () {
    Route::get('/', [AbsensiController::class, 'index']);
    Route::post('/{id}/approve', [AbsensiController::class, 'approve']);
    Route::post('/{id}/reject', [AbsensiController::class, 'reject']);
});

// 2. Tambah menu di database
INSERT INTO menus (label, icon, menu_link, index) 
VALUES ('Approval Absensi', 'calendar_month', '/absensi/approval', 5);
```

### **Frontend (Flutter):**
```
TIDAK PERLU UPDATE CODE APAPUN! 
Aplikasi otomatis:
- Menampilkan menu baru di dashboard
- Resolve route /absensi/approval
- Buat GenericApprovalPage dengan apiUrl: "/api/absensi"
- Load data dari GET /api/absensi
- Handle approve/reject dengan POST /api/absensi/{id}/approve
- Semua bekerja otomatis!
```

---

## 🚀 Keuntungan Arsitektur Ini

1. **Scalability**: Mudah menambah master baru tanpa update frontend
2. **Maintainability**: Business logic di backend, frontend hanya render
3. **Flexibility**: Backend bisa ubah struktur tanpa update app
4. **Role-Based**: Menu dan data berbeda per role, dikontrol backend
5. **Consistency**: Satu pattern untuk semua master
6. **Testing**: Mudah test karena logic terpisah

---

## 📌 Summary

Aplikasi ini menggunakan **Server-Driven Architecture** dimana:
- ✅ Menu, routes, data structure, dan business logic dikontrol backend
- ✅ Frontend hanya render berdasarkan data dari server
- ✅ Menambah fitur baru tidak perlu update frontend code
- ✅ Routing 100% dinamis dari menuLink server
- ✅ Approval level ditentukan backend berdasarkan token
- ✅ Field mapping dinamis dari config API
- ✅ Retry/backoff untuk network reliability
- ✅ Conflict handling untuk race conditions
- ✅ Tracing headers untuk debugging

**Result**: Aplikasi yang sangat fleksibel dan mudah di-scale!
