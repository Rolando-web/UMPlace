# UMPlace – Project Documentation

## 1. Application Proposal

**Application Title:** UMPlace – University of Mindanao Marketplace

### 1.1. Purpose of the Application
UMPlace is envisioned as a highly secure, student-exclusive marketplace specifically tailored for the University of Mindanao community. The primary purpose of this application is to provide a trusted, campus-only platform where students can buy, sell, and trade items conveniently. By integrating secure payment gateways and trust-based community features, the app fosters affordability, sustainability, and resource sharing among students. It aims to alleviate the financial burden on students by allowing them to purchase second-hand textbooks, uniforms, and gadgets at lower prices, while also giving them a platform to monetize items they no longer need.

**Target Users:**
*   **Student Sellers** – Active UM students who want to list and sell items they no longer need, creating an additional income stream while decluttering.
*   **Student Buyers** – UM students looking for affordable, reliable second-hand or peer-to-peer items without the risks associated with public marketplaces.
*   **Admin** – University staff or designated moderators who verify student identities, manage active listings, and monitor transactions to ensure platform integrity.

### 1.2. Problems it Aims to Solve
Currently, students heavily rely on informal selling methods like public social media groups or general classified ads, which present several critical issues:

**Problem 1: Lack of Trust and Platform Exclusivity**
Because anyone can join general social media groups, fake profiles, fraud, and duplicate listings are incredibly common.
*   **Solution 1:** To establish a secure and exclusive community, UMPlace restricts access strictly to verified University of Mindanao students by enforcing Google Sign-In via `@umindanao.edu.ph` accounts.

**Problem 2: High Risk of Financial Scams**
Students face significant financial risks when sending money online upfront to strangers without any guarantee of receiving the item.
*   **Solution 2:** To eliminate the risk of online selling scams, UMPlace integrates a secure escrow payment system that safely holds the buyer's funds until both parties confirm the successful physical turnover of the item.

**Problem 3: Unregulated Disputes and Unsafe Environments**
Informal marketplaces lack moderation, leaving students without support during disagreements or exposing them to physical dangers when meeting unverified strangers.
*   **Solution 3:** To ensure fairness and a safe campus environment, UMPlace provides a robust admin dashboard for designated moderators to oversee user trust scores, verify student identities, and resolve transaction disputes.

### 1.3. Key Features and Functionalities
*   **Trust and Exclusivity:** The system enforces Google Sign-In, strictly accepting only `@umindanao.edu.ph` accounts. This ensures every user is a verifiable member of the institution.
*   **Accessibility and Convenience:** Designed with a mobile-first philosophy, the application offers seamless listing creation, intuitive browsing, and a built-in real-time chat system for negotiations.
*   **Secure Transactions:** An integrated escrow payment system via GCash and Maya (powered by PayMongo) holds funds securely. The seller only receives the money once the buyer confirms receipt of the item, protecting both parties.
*   **Trust Score System:** A dynamic, feedback-based rating system (ranging from 0 to 100) rewards good behavior. High trust scores unlock premium features like increased listing limits, while low scores restrict user capabilities.
*   **Admin Tools:** A comprehensive dashboard allows administrators to perform manual ID verification, manage flagged listings, monitor ongoing transactions, and resolve user disputes efficiently.

### 1.4. Type of Application
*   **Mobile Application (Student Facing):** Developed using the Flutter framework to ensure high-performance, cross-platform compatibility across both Android and iOS devices from a single codebase.
*   **Web Application (Admin Dashboard):** Leveraging Flutter Web to provide a robust, responsive desktop-class management portal for administrators. This allows university staff to oversee users, verify IDs, manage reports, and monitor transactions conveniently from any standard web browser without needing to install an app.

---

## 2. Software Requirements Specification (SRS)

### 2.1. Functional Requirements
*   **Authentication & Authorization:** The system must authenticate users strictly via Google OAuth, automatically rejecting any non-university email domains.
*   **Listing Management:** Verified users must be able to create listings with multiple image uploads, detailed descriptions, and categorized tags. They must also be able to edit or archive their active listings.
*   **Transaction Processing:** The system must generate secure checkout links via PayMongo, process GCash/Maya payments, and accurately reflect the escrow status (pending, paid, released) in real-time.
*   **In-App Messaging:** Users must be able to communicate privately. The chat must be strictly tied to specific listings to keep conversations contextually relevant.
*   **Verification Workflow:** Users must be able to capture and upload a photo of their valid Student ID. The system will queue this for manual admin review to grant a 'Verified' badge.
*   **Administrative Control:** Admins must have the ability to ban users, take down inappropriate listings, and manually disburse escrow funds in the event of a dispute.

### 2.2. Non-Functional Requirements
*   **Performance:** The application must provide a snappy user experience. Real-time data synchronization (such as receiving a chat message or a payment confirmation) must reflect in the UI within 1 to 2 seconds.
*   **Security:** All API keys, especially PayMongo Secret Keys, must be securely managed. User data and transaction histories must be protected via strict Firebase Firestore Security Rules to prevent unauthorized read/write access.
*   **Usability:** The user interface must adhere to modern design principles, offering an intuitive, aesthetically pleasing experience that requires zero training for a student to use.
*   **Reliability:** Utilizing Firebase as the backend infrastructure ensures 99.9% uptime, handling concurrent connections effortlessly even during peak campus hours.

### 2.3. System Scope and Limitations
*   **Scope:** The application's ecosystem is entirely closed to the University of Mindanao. External users, alumni without active emails, and the general public cannot participate.
*   **Limitations:** While the app secures the financial transaction via escrow, the physical handover of the item is strictly peer-to-peer. The system cannot physically track the delivery of goods. Additionally, fully automated payouts to sellers may require manual admin batch processing depending on PayMongo's disbursement API limits.

---

## 3. Application Development Process

### 3.1. Software Development Life Cycle (SDLC) & Chosen Model
The project utilizes the **Agile Prototyping Model**. This iterative approach breaks the development down into manageable sprints, focusing on rapid delivery of functional components.

### 3.2. Justification
Developing a marketplace involves complex interactions between buyers, sellers, and the payment gateway. The Agile Prototyping model is highly justified because:
*   **Rapid Iteration:** It allows the team to build a visual prototype of the escrow UI early on. We can test how users interact with the checkout flow before writing complex backend logic.
*   **Flexibility and Adaptability:** Integrating third-party services like Firebase and PayMongo often introduces unforeseen technical hurdles. Agile allows the development team to pivot and refactor code without derailing the entire project timeline.
*   **User-Centric Refinement:** By continuously testing small modules (like the chat system or the listing upload), we ensure the final product perfectly aligns with the expectations of the student body.

---

## 4. UI/UX Design (Flutter)

### 4.1. Navigation Flow
The navigation is designed to be completely frictionless. 
*   **Student Flow:** Users begin at the Splash Screen, authenticate via Login, and land on the Home Feed. From there, they can tap a listing to view Details, seamlessly transition into Chat for negotiations, and proceed to the Payment Portal. A dedicated Profile tab manages their listings and transaction history.
*   **Admin Flow:** Administrators access a separate, secure Dashboard featuring distinct tabs for Verification requests, active Listings management, User oversight, and financial Analytics.

### 4.2. Responsive and Adaptive Design
The application guarantees a flawless layout across all device dimensions by utilizing Flutter's `MediaQuery` and `LayoutBuilder`. On standard smartphones, the UI employs a single-column, infinitely scrolling feed. On larger tablet screens, the layout dynamically adapts into dual-pane views—for instance, allowing users to browse the marketplace on the left while maintaining an active chat window on the right.

### 4.3. Widget Structure and Styling
*   **Brand Identity:** The app features a centralized `ThemeData` that strictly adheres to UM's branding guidelines, utilizing signature colors (Red `#B22222`, Yellow `#FFD700`, Green `#228B22`) paired with the highly legible 'Inter' font family.
*   **Advanced Visuals:** 
    *   **Hero Animations:** Providing butter-smooth visual continuity when transitioning from a small listing thumbnail to a full-screen image gallery.
    *   **Slivers:** Implementing collapsible, dynamic app bars that maximize screen real estate when scrolling through the feed.
    *   **Skeleton Loaders (Shimmer):** Enhancing perceived performance by displaying placeholder animations while Firebase data is being fetched over the network.

---

## 5. Firestore Database Design

### 5.1. Collections and Documents Structure
The system leverages Firebase Cloud Firestore, utilizing a scalable NoSQL document-oriented structure perfectly suited for real-time applications.

*   **`users` Collection:** Stores core identity data. Fields include `uid`, `email`, `displayName`, `trustScore` (integer 0-100), `verificationStatus` (enum: 'none', 'pending', 'verified', 'rejected'), and a map of `paymentMethods`.
*   **`listings` Collection:** Contains marketplace inventory. Fields include `id`, `title`, `price`, `category`, detailed `description`, `sellerId`, item `condition`, an array of image URLs (`images`), and the current `status` ('active', 'sold', 'archived').
*   **`transactions` Collection (Escrow Core):** Manages the financial lifecycle. Fields include `id`, `buyerId`, `sellerId`, linked `listingId`, total `amount`, platform `commission`, the real-time `status` ('pending', 'paid', 'released', 'refunded'), and the `paymongoPaymentId` for cross-referencing.
*   **`chats` & `messages` Collections:** Structured as sub-collections to facilitate real-time, low-latency conversational queries between two specific users regarding a specific item.

### 5.2. Data Flow & CRUD Operations
When a seller creates a new listing (Create), the images are uploaded to cloud storage, and a document is instantiated in Firestore. Buyers continuously read from this collection, utilizing complex queries to filter by category or price. When a purchase is initiated, a Transaction document is created. As the PayMongo API confirms payment, the backend updates the transaction status (Update), which triggers UI changes across both the buyer's and seller's devices simultaneously.

---

## 6. REST API Integration

### 6.1. API Used
The system relies heavily on the **PayMongo API** to handle all financial processing, allowing students to pay securely using local e-wallets like GCash and Maya.

### 6.2. Sample Endpoints
*   **Create Payment Intent:** `POST https://api.paymongo.com/v1/payment_intents` (Used for modern, robust payment flows).
*   **Create Source:** `POST https://api.paymongo.com/v1/sources` (Used for straightforward e-wallet redirects).

### 6.3. Request and Response Format
*   **Format:** Strict JSON formatting with Bearer Token / Basic Authentication.
*   **Sample Request (Payment Source):**
    ```json
    {
      "data": {
        "attributes": {
          "amount": 50000, 
          "type": "gcash",
          "currency": "PHP",
          "redirect": {
            "success": "umplace://payment-success",
            "failed": "umplace://payment-failed"
          }
        }
      }
    }
    ```
    *(Note: The amount is represented in centavos, so 50000 equals PHP 500.00).*
*   **Sample Response:** The PayMongo server returns a detailed JSON object containing the unique source `id`, current status, and a `checkout_url`. The Flutter app intercepts this URL and redirects the user to the GCash/Maya portal to authorize the charge.

### 6.4. Purpose in System
This integration is the backbone of the **Escrow feature**. By facilitating secure, verifiable online payments, it eliminates the need for students to carry physical cash. It guarantees that the buyer's money is safely held by the system until the physical item is successfully turned over, effectively neutralizing the risk of online selling scams.

---

## 7. Software Testing & Test Cases

### 7.1. Testing Strategies
To ensure a flawless launch, the application undergoes rigorous testing layers:
*   **Unit Testing:** Validating isolated logic, such as ensuring the `trustScore` algorithm correctly calculates the maximum allowed active listings for a given user.
*   **Integration Testing:** Ensuring the Flutter frontend communicates flawlessly with Firebase, such as verifying that tapping "Send" in the chat immediately writes a document to Firestore and triggers a listener.
*   **System Testing:** Comprehensive end-to-end (E2E) testing simulating real-world usage—from logging in, to creating a listing, to simulating a successful PayMongo transaction using sandbox credentials, and finally releasing the escrow.

### 7.2. Test Case Table

| Test Case ID | Title | Precondition | Test Steps | Expected Results | Actual Results | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-001** | Valid Campus Email Login | User has an active `@umindanao.edu.ph` account. | 1. Tap Google Sign-in. <br>2. Select university email. | System successfully authenticates user and redirects to the Home Dashboard. | System successfully authenticated and navigated to Home. | **Passed** |
| **TC-002** | Invalid Domain Rejection | User has a standard `@gmail.com` account. | 1. Tap Google Sign-in. <br>2. Select personal Gmail. | System rejects login and displays "Unauthorized Domain" error message. | System rejected login, error snackbar appeared correctly. | **Passed** |
| **TC-003** | Trust Score Listing Limit Enforcement | Seller's trust score is below 60. | 1. Navigate to Create Listing. <br>2. Fill details. <br>3. Tap Submit. | System blocks submission and displays a warning about low trust score limits. | System blocked submission and showed the accurate error dialog. | **Passed** |
| **TC-004** | Initiate Escrow via PayMongo | Buyer has sufficient GCash balance; Listing is active. | 1. Tap 'Buy Now' on an item. <br>2. Select GCash. <br>3. Confirm amount. | System generates PayMongo checkout URL and redirects user to GCash portal. | System generated URL and successfully opened the in-app browser. | **Passed** |
| **TC-005** | Confirm Payment & Escrow Lock | PayMongo test payment is successful. | 1. Complete payment in GCash sandbox. <br>2. Redirect back to app. | Transaction status updates to 'Paid'. Listing status updates to 'Sold'. Funds locked. | Transaction and Listing statuses updated simultaneously in Firestore. | **Passed** |
| **TC-006** | Submit ID for Verification | User has an unverified profile. | 1. Go to Profile. <br>2. Tap 'Verify Account'. <br>3. Upload Student ID image. | Image is uploaded to storage; User status changes to 'Pending' for Admin review. | Image uploaded successfully, profile UI reflects 'Pending' badge. | **Passed** |
| **TC-007** | Admin Dashboard Access Control | User attempting access is a standard student. | 1. Attempt to navigate to the Admin Dashboard route via deep link. | System denies access and forces redirection back to the Home Feed. | System denied access and redirected to Home Feed immediately. | **Passed** |
| **TC-008** | Real-time Chat Synchronization | Buyer and Seller have the chat screen open. | 1. Buyer sends a message. <br>2. Seller observes screen. | Message appears on Seller's screen within 2 seconds without page refresh. | Message appeared instantaneously with smooth fade-in animation. | **Passed** |
| **TC-009** | Large Image Upload Handling | User attempts to upload a 15MB 4K image for a listing. | 1. Select large image. <br>2. Submit listing. | System automatically compresses image before upload to prevent slow load times. | System took too long to compress and crashed the UI thread on older devices. | **Failed** |

*(Note: TC-009 indicates a known edge-case bug requiring the implementation of background isolates for heavy image compression).*

---

## 8. Application Metadata

*   **App Name:** UMPlace
*   **Version:** 1.0.0+1
*   **Developer Name:** Basuge La
*   **Platform:** Android, iOS, Web
*   **Description:** A trusted, exclusive campus marketplace for University of Mindanao students to buy, sell, and share resources securely. It integrates escrow payments and stringent identity verification to ensure a safe peer-to-peer ecosystem.
*   **Permissions Required:**
    *   `Internet`: Crucial for real-time Firebase synchronization and PayMongo API communication.
    *   `Camera`: Required to capture live photos for Student ID verification and listing creation.
    *   `Storage (Read/Write)`: Needed to select gallery images for products and cache downloaded assets for performance.
    *   `Network State`: Used to detect connection drops and gracefully handle offline scenarios.
