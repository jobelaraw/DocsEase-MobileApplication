class AppLocalizations {
  static const Map<String, Map<String, String>> _translations = {
    'English': {},
    'Filipino': {
      // Side bar / Navigation
      'Home': 'Home',
      'Profile': 'Profile',
      'About': 'About',
      'Settings': 'Settings',
      'Citizen User': 'Mamamayan',
      'Logout': 'Mag-logout',
      'Exit': 'Mag-exit',

      // Services
      'Services': 'Mga Serbisyo',
      'Search service...': 'Maghanap ng serbisyo...',
      'See All': 'Tingnan Lahat',
      'No services available.': 'Walang bakanteng serbisyo.',
      'Information': 'Impormasyon',

      // Profile
      'Edit Profile': 'I-edit ang Profile',
      'Service History': 'Kasaysayan ng Serbisyo',
      'No service history yet.\nStart a service to track your progress!':
          'Wala pang kasaysayan ng serbisyo.\nMagsimula ng serbisyo para masubaybayan ang iyong progreso!',
      'In Progress': 'Kasalukuyang Ginagawa',
      'Completed': 'Tapos Na',

      // Settings
      'APPEARANCE': 'HITSURA',
      'Dark Mode': 'Dark Mode',
      'Language': 'Wika',
      'ACCESSIBILITY': 'AKSESIBILIDAD',
      'Font Size': 'Laki ng Letra',
      'Save Changes': 'I-save ang Pagbabago',
      'Select Language': 'Pumili ng Wika',

      // About Us
      'The Team': 'Ang Team',
      'Creators': 'Mga Lumikha',
      'Connect With Us': 'Makipag-ugnayan sa Amin',
      'Active Users': 'Mga Active na Users',
      'App Store Rating': 'Rating sa App Store',

      // Chatbot
      'Chatbot': 'Chatbot',
      'DocsEase Bot': 'DocsEase Bot',
      'Online Assistant': 'Online Assistant',
      'Offline - Waiting for network...':
          'Offline - Naghihintay ng koneksyon...',
      'Ask about your transaction...':
          'Magtanong tungkol sa iyong transaksyon...',
      'Go to Home': 'Pumunta sa Home',
      'Go to Settings': 'Pumunta sa Settings',
      'Go to Profile': 'Pumunta sa Profile',
      'Go to About': 'Pumunta sa About',
      'Related Services': 'Mga Kaugnay na Serbisyo',
      'Commonly requested document procedures:': 'Mga karaniwang hinihinging proseso ng dokumento:',
      'Quick Access': 'Mabilis na Access',
      'Quick Access for': 'Mabilis na Access para sa',
      'Tap to view full details:': 'I-tap para makita ang buong detalye:',
      'Business Permit & Licensing': 'Permiso sa Negosyo at Lisensya',
      'City Civil Registry': 'Tagapagrehistro Sibil ng Lungsod',
      "City Engineer's Office": 'Opisina ng City Engineer',
      'Business Permit': 'Permiso sa Negosyo', 
      'Marriage Certificate': 'Sertipiko ng Kasal',
      'Building Permit': 'Permiso sa Pagtatayo ng Gusali',

      // Modals
      'Are you sure you want to exit?': 'Sigurado ka bang gusto mong lumabas?',
      'Changes will not be saved if you leave this page.':
          'Hindi mase-save ang mga pagbabago kung aalis ka sa pahinang ito.',
      'Yes': 'Oo',
      'Cancel': 'Kanselahin',
      'Changes Saved!': 'Na-save na ang Pagbabago!',
      'Updated successfully. Please click to continue.':
          'Matagumpay na na-update. Pindutin upang magpatuloy.',
      'Got it': 'Okay',
      'Confirm Changes': 'Kumpirmahin ang Pagbabago',
      'Are you sure you want to save changes?':
          'Sigurado ka bang gusto mong i-save ang pagbabago?',
      'Are you sure you want to logout?':
          'Sigurado ka bang gusto mong mag-logout?',
      'You have unsaved Settings changes that will be lost.':
          'Mayroon kang hindi na-save na mga pagbabago sa Settings na mawawala.',
      'Check your Email': 'Suriin ang iyong Email',
      'A recovery code has been sent to your email. Please check your inbox.':
          'Naipadala na ang recovery code sa iyong email. Suriin ang iyong inbox.',
      'Profile Requires Sign in': 'Kailangan mag-sign in para sa Profile',
      "You'll be directed to sign in screen. Are you sure you want to continue?":
          'Ire-redirect ka sa sign in screen. Sigurado ka bang gusto mong magpatuloy?',
      'Verified': 'Kumpirmado',
      'Code verified successfully. You may now change your password.':
          'Matagumpay na na-verify ang code. Maaari mo nang palitan ang iyong password.',
      'New Code Sent': 'Naipadala na ang Bagong Code',
      "We've sent a new recovery code. Please check your inbox for the updated 6-digit recovery code.":
          'Nagpadala kami ng bagong recovery code. Suriin ang iyong inbox para sa bagong 6-digit na recovery code.',

      // Information screen
      'No description available.': 'Walang available na paglalarawan.',
      'Requirements Checklist': 'Talaan ng mga Kinakailangan',
      'Step-by-Step Guide': 'Sunod-sunod na Gabay',
      'Mark As Done': 'Markahan Bilang Tapos',
      'Fee': 'Bayarin',
      'Processing Time': 'Tagal ng Pagproseso',
      'Person In-charge': 'Taong Namamahala',
      'LOCATION': 'LOKASYON',
      'CONTACT': 'KONTAK',
      'OFFICE SCHEDULE': 'ORAS NG OPISINA',
      'OPEN NOW': 'BUKAS NGAYON',
      'Secure at': 'Kunin sa',

      'A mobile assistant designed to help citizens navigate government services more easily in Binan City Hall. It provides clear information, guided steps, and smart navigation to simplify document processing in government offices.':
          'Isang mobile assistant na idinisenyo upang tulungan ang mga mamamayan na mas madaling mag-navigate sa mga serbisyo ng gobyerno sa Binan City Hall. Nagbibigay ito ng malinaw na impormasyon, mga gabay na hakbang, at matalinong nabigasyon upang gawing simple ang pagproseso ng mga dokumento sa mga tanggapan ng gobyerno.',
      'Service details not found.': 'Hindi nakita ang detalye ng serbisyo.',
    },
  };

  static String translate(String key, String language) {
    if (language == 'English') return key;
    return _translations[language]?[key] ?? key;
  }
}
