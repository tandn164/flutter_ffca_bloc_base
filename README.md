# flutter bloc base

Flutter Clean Architecture with BLoC

## 🏗️ Clean Architecture Setup

This project implements Clean Architecture with SOLID principles and BLoC for state management.

### Architecture Layers

```
┌─────────────────────────────────────────┐
│            Presentation Layer           │
│    (UI, BLoC, Pages, Widgets)           │
├─────────────────────────────────────────┤
│             Domain Layer                │
│    (Entities, Use Cases, Repositories)  │
├─────────────────────────────────────────┤
│              Data Layer                 │
│  (Data Sources, Repository Impls, DTOs) │
└─────────────────────────────────────────┘
```

### 📦 Entities, DTOs, and Models

#### 🎯 Entity (Domain Layer)
**Purpose**: Core business objects that represent the heart of your application

**Characteristics:**
- Contains business logic and rules
- Independent of external frameworks
- Immutable and pure
- No JSON serialization annotations
- Lives in `domain/entities/`

**Example:**
```dart
// domain/entities/user.dart
class User extends Equatable {
  final String id;
  final String email;
  final String username;
  final DateTime createdAt;
  final bool isVerified;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    required this.isVerified,
  });

  // Business logic methods
  bool canCreate() => isVerified && email.isNotEmpty;
  
  String get displayName => username.isEmpty ? email : username;

  @override
  List<Object?> get props => [id, email, username, createdAt, isVerified];
}
```

#### 📡 DTO (Data Transfer Object - Data Layer)
**Purpose**: Data containers for API communication and serialization

**Characteristics:**
- Contains JSON serialization/deserialization
- Maps directly to API response structure
- No business logic
- Mutable (can have setters)
- Lives in `data/models/` or `data/dto/`

**Example:**
```dart
// data/models/user_dto.dart
import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  @JsonKey(name: 'user_id')
  final String id;
  
  @JsonKey(name: 'email_address')
  final String email;
  
  @JsonKey(name: 'display_name')
  final String username;
  
  @JsonKey(name: 'created_timestamp')
  final String createdAt;
  
  @JsonKey(name: 'is_email_verified')
  final bool isVerified;

  const UserDto({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    required this.isVerified,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  // Convert DTO to Entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      username: username,
      createdAt: DateTime.parse(createdAt),
      isVerified: isVerified,
    );
  }

  // Convert Entity to DTO
  factory UserDto.fromEntity(User user) {
    return UserDto(
      id: user.id,
      email: user.email,
      username: user.username,
      createdAt: user.createdAt.toIso8601String(),
      isVerified: user.isVerified,
    );
  }
}
```

#### 🎨 Model (Presentation Layer)
**Purpose**: UI-specific data structures for state management

**Characteristics:**
- Optimized for UI rendering
- May combine multiple entities
- Contains UI state (loading, error states)
- Lives in `presentation/models/`

**Example:**
```dart
// presentation/models/user_profile_model.dart
class UserProfileModel extends Equatable {
  final User user;
  final int count;
  final bool isLoading;
  final String? errorMessage;

  const UserProfileModel({
    required this.user,
    required this.count,
    this.isLoading = false,
    this.errorMessage,
  });

  // UI helper methods
  String get countText {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  bool get hasError => errorMessage != null;

  UserProfileModel copyWith({
    User? user,
    int? count,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserProfileModel(
      user: user ?? this.user, 
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    user, count, 
    isFollowing, isLoading, errorMessage
  ];
}
```

#### 🔄 Data Transformation Flow

```dart
API Response (JSON) → DTO → Entity → Model → UI Widget
     ↓               ↓      ↓        ↓         ↓
  Raw Data    Serialization Pure   UI State  Display
               Parsing    Business  Management
                         Logic
```

#### 📋 When to Use Each

**Use Entity when:**
- Representing core business concepts
- Implementing business rules and logic
- Working in use cases and domain services
- Need framework-independent objects

**Use DTO when:**
- Communicating with APIs
- Parsing JSON responses
- Storing data in local databases
- Data serialization/deserialization needed

**Use Model when:**
- Managing UI state in BLoC states
- Combining multiple entities for display
- Adding UI-specific properties (loading, error states)
- Optimizing data for specific screens

#### 🏗️ Project Structure Example

```bash
lib/screens/authentication/
├── data/
│   ├── models/
│   │   ├── user_dto.dart           # API data structure
│   │   └── login_request_dto.dart  # API request structure
│   ├── datasources/
│   └── repositories/
├── domain/
│   ├── entities/
│   │   ├── user.dart              # Pure business object
│   │   └── auth_token.dart        # Business concept
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── models/
    │   ├── auth_state_model.dart   # UI state structure
    │   └── login_form_model.dart   # Form state
    ├── blocs/
    └── pages/
```

### How Layers Interact

#### 🔄 Data Flow & Dependencies

```
UI Event → BLoC → Use Case → Repository Interface → Repository Impl → Data Source → API/DB
                     ↓              ↓                    ↓             ↓
                 Domain          Domain               Data          Data
```

#### 📋 Dependency Rules

1. **Presentation Layer** depends on **Domain Layer** only
2. **Domain Layer** is independent (no dependencies on outer layers)
3. **Data Layer** depends on **Domain Layer** only
4. Dependencies point **inward** (toward domain)

#### 🚀 Interaction Flow Example

**Login Feature Flow:**

```dart
// 1. UI triggers event
LoginButton.onPressed() 
  → BlocProvider.of<AuthBloc>(context).add(LoginEvent())

// 2. BLoC receives event and calls use case
AuthBloc.on<LoginEvent>()
  → loginUseCase.call(LoginParams())

// 3. Use case calls repository interface
LoginUseCase.call()
  → authRepository.login(email, password)

// 4. Repository implementation calls data source
AuthRepositoryImpl.login()
  → authDataSource.login(email, password)

// 5. Data source makes API call
AuthDataSourceImpl.login()
  → api.post('/login', {email, password})

// 6. Response flows back up
API Response → DataSource → Repository → UseCase → BLoC → UI
```

#### 🔧 Layer Responsibilities

**Presentation Layer:**
- UI components (Pages, Widgets)
- State management (BLoC)
- User input handling
- Navigation

**Domain Layer:**
- Business entities (User, Video, etc.)
- Business rules (Use Cases)
- Repository contracts (interfaces)
- Core business logic

**Data Layer:**
- API communication (DataSources)
- Repository implementations
- Data transformation (DTOs ↔ Entities)
- Local storage, caching

#### 🎯 Communication Patterns

**From UI to Data:**
```dart
// UI Layer
onPressed: () => context.read<AuthBloc>().add(LoginEvent(email, password))

// Presentation Layer (BLoC)
Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
  final result = await loginUseCase(LoginParams(email: event.email, password: event.password));
  // Handle result...
}

// Domain Layer (Use Case)
Future<Either<Failure, User>> call(LoginParams params) async {
  return await repository.login(params.email, params.password);
}

// Domain Layer (Repository Interface)
abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
}

// Data Layer (Repository Implementation)
Future<Either<Failure, User>> login(String email, String password) async {
  try {
    final userDto = await dataSource.login(email, password);
    return Right(userDto.toEntity());
  } catch (e) {
    return Left(ServerFailure());
  }
}

// Data Layer (Data Source)
Future<UserDto> login(String email, String password) async {
  final response = await api.post('/login', {'email': email, 'password': password});
  return UserDto.fromJson(response.data);
}
```

**Error Handling Flow:**
```dart
API Error → DataSource Exception → Repository Failure → UseCase Either<Failure, Success> → BLoC Error State → UI Error Display
```

### Feature Structure Pattern

Each feature follows this structure:
```bash
screens/feature_name/
├── data/
│   ├── datasources/          # API calls, local storage
│   │   └── feature_datasource.dart
│   └── repositories/         # Repository implementations
│       └── feature_repository_impl.dart
├── domain/
│   ├── entities/            # Business objects
│   ├── repositories/        # Repository interfaces
│   │   └── feature_repository.dart
│   └── usecases/           # Business logic
│       └── feature_usecase.dart
└── presentation/
    ├── blocs/              # State management
    │   ├── feature_bloc.dart
    │   ├── feature_event.dart
    │   └── feature_state.dart
    ├── pages/              # Screen widgets
    └── widgets/            # Feature-specific widgets
```

## 📁 Project Base Structure

```bash
lib/
├── core/                           # Shared across features
│   ├── base/
│   │   └── base_response.dart      # Base API response model
│   ├── error/
│   │   ├── exceptions.dart         # Custom exceptions
│   │   └── failures.dart          # Error handling
│   ├── network/
│   │   └── network_info.dart      # Internet connectivity
│   ├── usecases/
│   │   └── usecase.dart           # Base use case interface
│   ├── utils/
│   │   ├── constants.dart         # App constants
│   │   ├── router.dart           # Navigation routes
│   │   ├── theme.dart            # App theming
│   │   └── widget_utils.dart     # UI utilities
│   └── widgets/                   # Reusable UI components
├── generated/                     # Auto-generated files
│   ├── l10n/                     # Localization
│   └── swaggers/                 # API clients
├── interceptor/
│   ├── app_authenticator.dart    # Token refresh logic
│   └── auth_interceptor.dart     # HTTP interceptors
├── screens/                      # Feature modules
│   ├── authentication/
│   ├── home/
│   ├── profile/
│   ├── create_video/
│   └── global/                   # App-wide state
├── l10n/                         # Localization source
├── injection_container.dart      # Dependency injection
└── main.dart                     # App entry point
```

## 🔧 Code Generation Setup

### Dependencies for Code Generation

```yaml
dev_dependencies:
  build_runner: 2.3.3
  chopper_generator: 6.0.3
  json_serializable: 6.7.1
  swagger_dart_code_generator: 2.11.13
```

### Configuration Files

**build.yaml** - Build configuration:
```yaml
targets:
  $default:
    builders:
      swagger_dart_code_generator:
        options:
          chopper: true
          json_annotation: true
```

**l10n.yaml** - Localization configuration:
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: l10n.dart
output-class: S
```

### Code Generation Commands

```bash
# Generate Swagger API clients
flutter pub run build_runner build

# Generate localization files  
flutter gen-l10n

# Clean and regenerate (when conflicts occur)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes (development)
flutter pub run build_runner watch
```

## 🏭 Dependency Injection Setup

**injection_container.dart** structure:
```dart
final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => InternetConnectionChecker());
  
  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  
  // Data sources
  sl.registerLazySingleton<AuthenticationDataSource>(
    () => AuthenticationDataSourceImpl(sl()),
  );
  
  // Repositories
  sl.registerLazySingleton<AuthenticationRepository>(
    () => AuthenticationRepositoryImpl(sl(), sl()),
  );
  
  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  
  // BLoCs
  sl.registerFactory(() => LoginBloc(sl()));
}
```

## 🎯 BLoC Pattern Implementation

### Event-State-Bloc Structure

```dart
// Events
abstract class AuthEvent extends Equatable {}

class LoginEvent extends AuthEvent {
  final String email, password;
  LoginEvent({required this.email, required this.password});
}

// States
abstract class AuthState extends Equatable {}

class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure({required this.message});
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  
  AuthBloc({required this.loginUseCase}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
  }
  
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (success) => emit(AuthSuccess()),
    );
  }
}
```

## 🚀 Getting Started

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate code:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs   
   flutter gen-l10n
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```
