
**ROLE:**
You are a **Senior Flutter Architect**, **Security Engineer**, and **Supabase expert** specializing in real-time systems, end-to-end encrypted messaging, and secure ephemeral/anonymous channels.

**TASK:**
Build a **complete, production-ready Flutter chat application** using **Supabase** with **full end-to-end encryption**, a **modern gradient-free UI**, **group chat support**, **QR quick-add**, and an **anonymous shared-key (no-auth) chat option**. Deliver the **full Flutter project structure + all code**, together with embedded documentation that explains architecture, crypto, and operational notes.

---

## **HIGHLIGHTS / FEATURES TO IMPLEMENT**

* Email/password auth via Supabase (regular flow)
* One-to-one encrypted chats (E2EE)
* Group chats with secure group key distribution
* QR-based quick add (ID + public key)
* **Anonymous shared-key chat (no-auth)** — both users enter the same secret key (human or machine-generated). The system connects them into a private end-to-end encrypted session without requiring accounts.
* Encrypted media and files
* Typing indicators, read receipts, and presence (where possible)
* Riverpod-based state management and clean architecture
* UI: modern, unique, professional, **no gradients**

---

## **ADDITIONAL FEATURE: Anonymous Shared-Key (No-Auth) Chat — SPECIFICATION**

### **Goal**

Allow users to create/join a private chat session **without registering**. Two (or more) users who know the same secret key can enter it in the app and be connected to a private encrypted conversation with full privacy guarantees similar to an E2EE session.

### **User Flows**

1. **Create Anonymous Session**

   * User taps “Create anonymous session” → app generates a **high-entropy session key** (recommended: 32–64 bytes base64/URL-safe) and shows:

     * Human-readable code (optional, e.g., `WORD-PAIR-1234`) **and** machine key (recommended to copy/share via secure channels)
     * QR code that encodes the session descriptor (session ID + public bootstrap data)
     * Option: set expiration (e.g., 24h, 7d) and max participants
   * App displays ephemeral session lobby.

2. **Join Anonymous Session**

   * User taps “Join anonymous session” → enters the session key (or scan QR).
   * Client validates and boots the anonymous key-exchange process, then joins the session.

3. **Anonymous session characteristics**

   * No Supabase user account is required.
   * Clients create ephemeral local identities (ephemeral key pairs).
   * Supabase stores only **ciphertext** and minimal routing metadata (session id, encrypted sender blob).
   * Optional: allow conversion of anonymous session to an authenticated conversation (migrate keys) if user later registers.

### **Crypto Design (Concrete, implementable)**

> **Important:** Implementers must include thorough inline documentation describing trade-offs. The prompt should instruct Claude to produce *complete, correct, and production-ready code*, but also to clearly document security assumptions.

#### **Recommended approach (what Claude must implement):**

1. **Session Descriptor**

   * When creating a session, generate:

     * `session_id` (UUIDv4)
     * `session_secret` (256-bit random key; represent base64-url)
     * `session_metadata` (creation_ts, expiry, max_participants, optional human label)
   * Client displays the `session_secret` and a short human code (derived by hashing and mapping to words/numbers) plus a QR.

2. **Bootstrapping & Key Derivation**

   * Both parties provide the same `session_secret`.
   * Use a secure KDF (HKDF-SHA256) on `session_secret || session_id` to derive:

     * `master_sym_key` (used to encrypt group/session messages)
     * `bootstrap_seed` for ephemeral asymmetric key generation
   * From `bootstrap_seed`, derive a deterministic ephemeral X25519 keypair per device (so two devices with the same secret will be able to compute compatible keys). But to achieve **PFS (forward secrecy)**, generate a fresh ephemeral key pair per session and also perform an extra ephemeral Diffie-Hellman exchange between participants when possible:

     * Each client generates an ephemeral X25519 keypair (non-deterministic) and signs/encrypts its ephemeral public key using `master_sym_key` so other participants can perform DH to get per-peer session keys. This provides forward secrecy while still using the shared secret to authenticate the ephemeral keys.
   * Use libsodium primitives (`crypto_kdf`, `crypto_kx` / `x25519`, `crypto_aead_xchacha20poly1305_ietf`) via `flutter_sodium` (or vetted library).

3. **Message Encryption**

   * Use an AEAD cipher (XChaCha20-Poly1305) for message encryption.
   * Messages are encrypted with per-session symmetric keys derived from `master_sym_key` and per-message nonce (random or monotonic per-sender).
   * For one-to-one, perform pairwise shared secret via Diffie-Hellman (X25519) and then an AEAD cipher.
   * For group anonymous sessions, encrypt messages with the derived `group_session_key`. To provide confidentiality upon membership changes, support **group key rotation**.

4. **Key Rotation & Membership Changes**

   * If a new member joins or a member leaves, the session owner (or designated ephemeral coordinator) rotates the `group_session_key` and publishes the new key encrypted with the old key or distribute individually encrypted to each member using their ephemeral DH shared secret. Document tradeoffs and design.

5. **Replay & Brute Force Protections**

   * Rate-limit join attempts on the Supabase function layer (RLS / Postgres functions) to minimize brute-force guessing of session keys.
   * Encourage long, high-entropy keys for better security.
   * Offer optional passphrase-to-key helper using a strong KDF (scrypt/Argon2) if the user prefers human memorable passphrases (but warn about weaker security).

6. **Server (Supabase) Role**

   * Acts as a **dumb** message relay and storage for ciphertext. It knows `session_id`, message timestamps, and encrypted payloads only.
   * No plaintext allowed on server.
   * Optional ephemeral presence metadata (e.g., ephemeral user_id hash) that does not reveal identity.

7. **Privacy & UX Tradeoffs (Claude must document)**

   * Anonymous sessions are link-based security: anyone with the key can join.
   * If key leaked, session compromised. Recommend one-time keys or short expiry.
   * Convert-to-account migration flow must re-encrypt or securely transfer keys.
   * Explain limitations versus full account-based Signal-style identity verification.

### **UI additions required**

* New screen: **Create Anonymous Session** (generate/show keys & QR)
* New screen: **Join Anonymous Session** (enter key or scan QR)
* Session Lobby (list participants, initiate chat)
* In-chat banner for anonymous sessions with info: expiry, owner, participant count, "regenerate key" (owners)
* Settings option to make anonymous session public/private, set expiry, max participants

### **DB changes (Supabase)**

* Add table: `anonymous_sessions`:

  * `session_id` UUID (PK), `session_meta` JSONB (encrypted on client before storing sensitive fields), `created_at`, `expires_at`, `max_participants`, `owner_hash` (optional), `is_active`
* Messages remain in `messages` with `conversation_type` = `'anonymous'`, `conversation_id = session_id`, `ciphertext`, `nonce`, `sender_blob` (encrypted ephemeral sender info)
* RLS & policies to protect rate-limiting & restrict modifications server-side

---

## **DOCUMENTATION REQUIREMENTS (Must be produced in the output)**

For the anonymous shared-key feature Claude must include:

1. **Threat model & security assumptions** — exactly what the system protects against and what it does not
2. **Complete crypto flows** — key derivation, ephemeral keys, message encryption, key rotation, and conversion to authenticated accounts
3. **UI/UX flows** — how users create, share, join, and leave anonymous sessions
4. **Supabase schema & RLS policies** — SQL DDL and policy snippets to reduce abuse
5. **Operational recommendations** — expiry defaults, brute-force mitigation, logging practices (only safe metadata), recommended key length, and migration path to registered accounts
6. **Code comments** — every crypto function must be documented inline and reference the libsodium APIs used

---

## **EVERYTHING ELSE (unchanged from previous spec)**

### **UI/UX**

* No gradients anywhere; flat surfaces only
* Modern typography and spacing
* Unique, professional design (not a clone)
* Smooth micro-interactions (no heavy shadows)

### **Architecture**

* Riverpod for state management (or BLoC if requested)
* Folder structure must include `qr/`, `groups/`, `anonymous/`, and `encryption/` modules

### **Supabase**

* Auth, Realtime, Storage for encrypted media
* Realtime channels for messages, typing, presence, group metadata
* SQL schema for `profiles`, `conversations`, `conversation_members`, `group_metadata`, `messages`, `typing_status`, `presence`, `pending_contacts`, `anonymous_sessions`

### **Encryption**

* Use `flutter_sodium` or equivalent libsodium binding
* AEAD: XChaCha20-Poly1305
* KDF: HKDF-SHA256 for key derivation; recommend Argon2/scrypt if deriving from human passphrases
* Asymmetric: X25519 for DH; Ed25519 for signatures where needed

### **Output Format (Required)**

Claude must output the full project in this exact structure:

1. **Project Overview**
2. **Architecture & Folder Structure** (including `anonymous/` module)
3. **Database Schema (full SQL)** (including `anonymous_sessions` and RLS policies)
4. **Encryption Layer (full code)** (including anonymous session KDF & ephemeral key handling)
5. **Group Encryption Layer** (full code)
6. **QR Quick Add System** (full code)
7. **Anonymous Shared-Key Module** (full code: screens, services, Supabase integration, encryption)
8. **Complete Flutter Project Code** (file-by-file with runnable code)
9. **Theme & UI System** (no gradients)
10. **All Screens Implementations**
11. **Supabase Integration Code**
12. **How to Build & Run**
13. **Security Notes & Future Extensions**

### **CONSTRAINTS & DELIVERY**

* No gradients anywhere
* All code must be runnable and production-ready (no placeholders)
* Do not simplify the encryption layer — produce real, tested-sounding implementations (use libsodium primitives)
* Provide inline comments and a final documentation section explaining how to audit and verify the crypto
* Include tests for key crypto components (unit tests for KDFs, encryption/decryption, join/leave flows)

---

