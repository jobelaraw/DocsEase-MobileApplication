import 'package:flutter/material.dart';
import 'services.dart';

class ServiceLists {
  static const List<ServiceData> officeBusinessLicensing = [    
    // Business Permit and Licensing Section
    ServiceData(
      label: 'New Business Application', // 2 transactions
      icon: Icons.add_business_outlined,
      bgColor: Color.fromRGBO(222, 173, 235, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Renewal of Business Application', // 2 transactions
      icon: Icons.autorenew,
      bgColor: Color.fromRGBO(141, 224, 148, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Retirement of Business',
      icon: Icons.exit_to_app,
      bgColor: Color.fromRGBO(154, 144, 245, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Special Permit',
      icon: Icons.verified_outlined,
      bgColor: Color.fromRGBO(247, 176, 110, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Certificate of No Record',
      icon: Icons.fact_check,
      bgColor: Color.fromRGBO(216, 214, 80, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Permit Update Transactions',
      icon: Icons.edit_document,
      bgColor: Color.fromRGBO(163, 169, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Certificate of Business Status',
      icon: Icons.approval,
      bgColor: Color.fromRGBO(73, 182, 209, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Complaints and Violations',
      icon: Icons.report_problem,
      bgColor: Color.fromRGBO(216, 80, 209, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
  ];

// Office of the Building Section
  static const List<ServiceData> officeBuildingOfficial = [
    ServiceData(
      label: 'Construction Permits Application',
      icon: Icons.construction,
      bgColor: Color.fromRGBO(255, 167, 167, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Certificate of Final Electrical Inspection (CFEI) Application',
      icon: Icons.electrical_services,
      bgColor: Color.fromRGBO(185, 255, 191, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Issuance of Certificate of Annual Inspection',
      icon: Icons.verified,
      bgColor: Color.fromRGBO(170, 211, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Certificate of Occupancy Application', // 2 transactions
      icon: Icons.business,
      bgColor: Color.fromRGBO(255, 131, 183, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),      
  ];

  // Office of the City Engineer Section
  static const List<ServiceData> officeCityEngineer = [
    ServiceData(
      label: 'Project Preparation',
      icon: Icons.design_services,
      bgColor: Color.fromRGBO(249, 255, 162, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Project Implementation',
      icon: Icons.construction,
      bgColor: Color.fromRGBO(142, 196, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Repair and Maintenance of Streetlights',
      icon: Icons.lightbulb_outline,
      bgColor: Color.fromRGBO(151, 255, 246, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Project Preparation and Implementation for Barangays',
      icon: Icons.location_city,
      bgColor: Color.fromRGBO(255, 158, 158, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Issuance of New Tax Declaration', // 4 transactions
      icon: Icons.receipt_long,
      bgColor: Color.fromRGBO(255, 160, 239, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
     ServiceData(
      label: 'Issuance of Certified Copy of Tax Declarations, Tax Maps and Other Assessment Records', 
      icon: Icons.map,
      bgColor: Color.fromRGBO(255, 155, 155, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),   
  ];

  // Office of the City Assessor Section
  static const List<ServiceData> officeCityAssessor = [
    ServiceData(
      label: 'Issuance of New Tax Declaration', // 4 transactions
      icon: Icons.receipt_long,
      bgColor: Color.fromRGBO(154, 255, 167, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
     ServiceData(
      label: 'Issuance of Certified Copy of Tax Declarations, Tax Maps and Other Assessment Records', 
      icon: Icons.folder_copy,
      bgColor: Color.fromRGBO(214, 164, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ), 
    ServiceData(
      label: 'Issuance of Certification of Landholdings and Certificate of No Property', 
      icon: Icons.remove_circle_outline,
      bgColor: Color.fromRGBO(160, 255, 223, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ), 
    ServiceData(
      label: 'Issuance of Certificate of No Improvement', 
      icon: Icons.assignment_outlined,
      bgColor: Color.fromRGBO(209, 159, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),   
  ];

   // Office of the City Civil Registrar Section
  static const List<ServiceData> officeCivilRegistry = [
    ServiceData(
      label: 'Registration of Certificate of Live Birth (COLB) – Timely', // 2 transactions
      icon: Icons.child_care,
      bgColor: Color.fromRGBO(171, 249, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
     ServiceData(
      label: 'Registration of Marriage- Timely', // 2 transactions
      icon: Icons.volunteer_activism,
      bgColor: Color.fromRGBO(255, 244, 150, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ), 
    ServiceData(
      label: 'Registration of Death – Timely', 
      icon: Icons.sentiment_very_dissatisfied,
      bgColor: Color.fromRGBO(255, 143, 143, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ), 
    ServiceData(
      label: 'Issuance of Civil Registry Documents-Birth, Death & Marriages(Certificates and Certification)', 
      icon: Icons.description,
      bgColor: Color.fromRGBO(155, 255, 152, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ), 
    ServiceData(
      label: 'Application of Marriage License', 
      icon: Icons.celebration,
      bgColor: Color.fromRGBO(226, 154, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Registration and Annotation of Court Decree', 
      icon: Icons.gavel,
      bgColor: Color.fromRGBO(237, 164, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Delayed Registration (Birth, Marriage, Death)', //2 transactions
      icon: Icons.schedule,
      bgColor: Color.fromRGBO(255, 199, 154, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),  
    ServiceData(
      label: 'Petition for Correction of Clerical Error/Change of First Name)', 
      icon: Icons.drive_file_rename_outline,
      bgColor: Color.fromRGBO(255, 158, 158, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Legal Instruments', 
      icon: Icons.article,
      bgColor: Color.fromRGBO(162, 210, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Supplemental Report of Civil Registry Documents', 
      icon: Icons.post_add,
      bgColor: Color.fromRGBO(165, 255, 147, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ), 
  ];

// Office of the City Treasurer Section
  static const List<ServiceData> officeCityTreasurer = [
    ServiceData(
      label: 'Payment of Real Property Tax', //2 transactions
      icon: Icons.home_work,
      bgColor: Color.fromRGBO(150, 201, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
     ServiceData(
      label: 'Payment of Local Business Tax', // 2 transactions
      icon: Icons.store,
      bgColor: Color.fromRGBO(174, 255, 158, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ), 
    ServiceData(
      label: 'Requisitionof Real Property Tax Clearance', 
      icon: Icons.receipt_long,
      bgColor: Color.fromRGBO(255, 162, 224, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ), 
    ServiceData(
      label: 'Payment of 2% Gross Income Tax (PEZA)', 
      icon: Icons.trending_up,
      bgColor: Color.fromRGBO(154, 255, 205, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ), 
    ServiceData(
      label: 'Payment of Amusement Tax', 
      icon: Icons.celebration,
      bgColor: Color.fromRGBO(255, 149, 149, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Payment of Franchise Tax', 
      icon: Icons.corporate_fare,
      bgColor: Color.fromRGBO(248, 255, 145, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Payment of Transfer Tax of Real Property Ownership', 
      icon: Icons.swap_horiz,
      bgColor: Color.fromRGBO(154, 255, 216, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),  
    ServiceData(
      label: 'Payment of Professional Tax', 
      icon: Icons.badge,
      bgColor: Color.fromRGBO(215, 172, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Payment of Occupational or Calling Fee', 
      icon: Icons.work,
      bgColor: Color.fromRGBO(255, 157, 157, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Payment of Community Tax Certificate (Cedula)', //2 transactions
      icon: Icons.credit_card,
      bgColor: Color.fromRGBO(255, 163, 163, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ), 
    ServiceData(
      label: 'Payment of Clearance and Certification Fees', 
      icon: Icons.verified,
      bgColor: Color.fromRGBO(158, 255, 158, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Payment of Civil Registration Fees', 
      icon: Icons.description,
      bgColor: Color.fromRGBO(252, 154, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Payment of Cemetery Fees', 
      icon: Icons.local_florist,
      bgColor: Color.fromRGBO(255, 205, 163, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Payment of Permit Fees for Building, Electrical, and Occupancy', 
      icon: Icons.construction,
      bgColor: Color.fromRGBO(168, 255, 222, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Payment of Zoning Clearance Fees', 
      icon: Icons.map,
      bgColor: Color.fromRGBO(146, 144, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Payment of Traffic Violation Fees', 
      icon: Icons.traffic,
      bgColor: Color.fromRGBO(216, 159, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Payment of Public Market Stall Rental and Electric Fees', 
      icon: Icons.shopping_basket,
      bgColor: Color.fromRGBO(138, 195, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Payment of Sealing and Licensing Fees of Weights and Measures', 
      icon: Icons.scale,
      bgColor: Color.fromRGBO(200, 255, 156, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Payment of Franchising and Licensing Fees', 
      icon: Icons.receipt,
      bgColor: Color.fromRGBO(255, 217, 161, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Payment of Rental Fees of Real Properties Owned by the City', 
      icon: Icons.apartment,
      bgColor: Color.fromRGBO(255, 152, 152, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
  ];

// Office of the City Mayor Section
  static const List<ServiceData> officeCityMayor = [
    ServiceData(
      label: 'Schedule of Civil Wedding',
      icon: Icons.celebration,
      bgColor: Color.fromRGBO(255, 168, 157, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Processing of Request/Reports/Correspondence from Agencies, NGOs, Private Individuals',
      icon: Icons.mark_email_read,
      bgColor: Color.from(alpha: 1, red: 0.529, green: 0.757, blue: 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'CCTV Record Review Request',
      icon: Icons.videocam,
      bgColor: Color.fromRGBO(155, 165, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Mayor’s Clearance',
      icon: Icons.admin_panel_settings,
      bgColor: Color.fromRGBO(255, 156, 238, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'HAPI CARD – Health Assistance Program for Indigent Families',
      icon: Icons.health_and_safety,
      bgColor: Color.fromRGBO(160, 255, 173, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Meralco Waiver',
      icon: Icons.electrical_services,
      bgColor: Color.fromRGBO(255, 131, 131, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Securing Legislative Document',
      icon: Icons.gavel,
      bgColor: Color.fromRGBO(253, 255, 155, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Travel Order for Officials',
      icon: Icons.flight_takeoff,
      bgColor: Color.fromRGBO(164, 255, 247, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Obligation Slip / Vouchers / PR / PO / Cheque',
      icon: Icons.payments,
      bgColor: Color.fromRGBO(210, 155, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
  ];

  // Office of the City Vice Mayor/ SP & Secretary to the Sanggunian Section
  static const List<ServiceData> officeCityVmSpSecretarySangunian = [
    ServiceData(
      label: 'Securing Legislative Document',
      icon: Icons.gavel,
      bgColor: Color.fromRGBO(175, 214, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
  ];  

  // Information and Communications Technology Office Section
  static const List<ServiceData> officeICT = [
    ServiceData(
      label: 'ICTO Tech4ed Center Clients',
      icon: Icons.people,
      bgColor: Color.fromRGBO(161, 255, 161, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'ICTO Tech4ed Center Training',
      icon: Icons.computer,
      bgColor: Color.fromRGBO(255, 231, 154, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'ICTO Online Helpdesk',
      icon: Icons.headset_mic,
      bgColor: Color.fromRGBO(255, 158, 231, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'ICTO Project Request',
      icon: Icons.settings_suggest,
      bgColor: Color.fromRGBO(255, 173, 221, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
  ];

  // City Human Resources and Development Office Section
  static const List<ServiceData> officeCityHRDevelopment = [
    ServiceData(
      label: 'Recruitment',
      icon: Icons.person_add,
      bgColor: Color.fromRGBO(223, 255, 164, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Selection',
      icon: Icons.how_to_reg,
      bgColor: Color.fromRGBO(255, 148, 246, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Placement',
      icon: Icons.badge,
      bgColor: Color.fromRGBO(255, 163, 163, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Placement',
      icon: Icons.work_history,
      bgColor: Color.fromRGBO(255, 164, 225, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Securing Personal Documents from the 201 Files',
      icon: Icons.folder_shared,
      bgColor: Color.fromRGBO(255, 149, 149, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
  ];

// Public Employment Services Office Section
  static const List<ServiceData> officePublicEmploymentServices = [
    ServiceData(
      label: 'Securing Local Employment Referrals for Jobseekers',
      icon: Icons.work,
      bgColor: Color.fromRGBO(154, 203, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Company Accreditation',
      icon: Icons.verified,
      bgColor: Color.fromRGBO(255, 173, 241, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'OFW Help Desk',
      icon: Icons.support_agent,
      bgColor: Color.fromRGBO(255, 161, 161, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Availing Special Program for Employment of Students',
      icon: Icons.school,
      bgColor: Color.fromRGBO(253, 205, 159, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
  ];

  // Office of the City Environmental and Natural Resources Officer Section
  static const List<ServiceData> officeCENR = [
    ServiceData(
      label: 'Application of Environmental Clearance',
      icon: Icons.eco,
      bgColor: Color.fromRGBO(255, 174, 221, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Registration of Waste Transporter',
      icon: Icons.local_shipping,
      bgColor: Color.fromRGBO(159, 255, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Securing Permit to Cut Trees',
      icon: Icons.forest,
      bgColor: Color.fromRGBO(255, 163, 163, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Provision of Equipment and Technical Assistance to Barangay MRF',
      icon: Icons.build_circle,
      bgColor: Color.fromRGBO(255, 154, 154, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Establishment of Tree Parks and Greenbelts / Urban Ecosystem Development',
      icon: Icons.park,
      bgColor: Color.fromRGBO(177, 255, 167, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
  ];

  // Office of the City Population Officer Section
  static const List<ServiceData> officeCityPopulationOfficer = [
    ServiceData(
      label: 'Pre-Marriage Orientation',
      icon: Icons.favorite,
      bgColor: Color.fromRGBO(255, 163, 209, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
  ];

  // Office of the City Cooperatives Officer Section
  static const List<ServiceData> officeCityCooperativesOfficer = [
    ServiceData(
      label: 'Assistance in the Conduct of Pre-Registration Seminar (PRS)',
      icon: Icons.groups,
      bgColor: Color.fromRGBO(194, 255, 166, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
  ];

  // Office of the City Information Officer Section
  static const List<ServiceData> officeCityInformationOfficer = [
    ServiceData(
      label: 'Online Inquiry',
      icon: Icons.public,
      bgColor: Color.fromRGBO(188, 253, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Full Disclosure Policy Portal (FDPP)',
      icon: Icons.verified,
      bgColor: Color.fromRGBO(255, 247, 174, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Benchmarking Activity',
      icon: Icons.analytics,
      bgColor: Color.fromRGBO(234, 166, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Tarpaulin Printing',
      icon: Icons.print,
      bgColor: Color.fromRGBO(255, 208, 163, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
  ];

  // Office of the City Social Welfare and Development Officer Section
  static const List<ServiceData> officeCSWD = [
    ServiceData(
      label: 'Early Childhood Care and Development Program',
      icon: Icons.child_care,
      bgColor: Color.fromRGBO(255, 188, 188, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Self Employment Assistance Program',
      icon: Icons.work,
      bgColor: Color.fromRGBO(180, 216, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Assistance to Individuals in Crisis Situation (AICS)',
      icon: Icons.health_and_safety,
      bgColor: Color.fromRGBO(253, 255, 163, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Social Pension for Biñan-OSCA Registered Senior Citizens',
      icon: Icons.elderly,
      bgColor: Color.fromRGBO(255, 189, 172, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Issuance of Person with Disability (PWD) and Senior Citizen ID',
      icon: Icons.badge,
      bgColor: Color.fromRGBO(255, 137, 137, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Social Case Study Report, Referral and Certification',
      icon: Icons.description,
      bgColor: Color.fromRGBO(166, 255, 158, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Registration of Solo Parent and Issuance of Identification Card (SPIC)',
      icon: Icons.family_restroom,
      bgColor: Color.fromRGBO(148, 255, 237, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Assistance to Children-in-Conflict with the Law (CICL) and Children-at-Risk (CAR)',
      icon: Icons.shield,
      bgColor: Color.fromRGBO(255, 166, 166, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Assistance to Victims of Domestic Violence, VAW, and Child Victims of Abuse',
      icon: Icons.report,
      bgColor: Color.fromRGBO(121, 250, 179, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Community-Based Reformation Program of Drug Personalities',
      icon: Icons.healing,
      bgColor: Color.fromRGBO(255, 255, 234, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
  ];

  // Office of the City Accountant Section
  static const List<ServiceData> officeCityAccount = [
    ServiceData(
      label: 'Processing of PhilHealth Refund',
      icon: Icons.health_and_safety,
      bgColor: Color.fromRGBO(175, 255, 161, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Processing of Disbursement Vouchers for Check Preparation (Payroll, Suppliers)',
      icon: Icons.payments,
      bgColor: Color.fromRGBO(255, 166, 181, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Issuance of Certified True Copy of Payslip',
      icon: Icons.receipt_long,
      bgColor: Color.fromRGBO(182, 255, 186, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
  ];
  // Office of the City Legal Officer Section
  static const List<ServiceData> officeCityLegalOfficer = [
    ServiceData(
    label: 'Request for Free Legal Advice',
    icon: Icons.gavel,
    bgColor: Color.fromRGBO(177, 215, 255, 1),
    iconColor: Color.fromRGBO(32, 87, 206, 1.0),
  ),
  ServiceData(
    label: 'Submission of Request for Contract Review',
    icon: Icons.description,
    bgColor: Color.fromRGBO(255, 224, 184, 1),
    iconColor: Color.fromRGBO(32, 87, 206, 1.0),
  ),
];

  // Office of the City Agriculturist Section
  static const List<ServiceData> officeCityAgriculturist = [
    ServiceData(
      label: 'Certified/Hybrid Seeds and Fertilizer Assistance (Subsidy)',
      icon: Icons.agriculture,
      bgColor: Color.fromRGBO(165, 209, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Seedlings Distribution',
      icon: Icons.eco,
      bgColor: Color.fromRGBO(255, 199, 199, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Vegetable Seeds Distribution',
      icon: Icons.set_meal,
      bgColor: Color.fromRGBO(225, 150, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Trainings and Seminar',
      icon: Icons.school,
      bgColor: Color.fromRGBO(255, 195, 176, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Municipal Fishing Vessel And Gear Registration System (BoatR)',
      icon: Icons.directions_boat,
      bgColor: Color.fromRGBO(190, 255, 176, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Municipal Fisherfolk Registration Program (FishR)',
      icon: Icons.anchor,
      bgColor: Color.fromRGBO(183, 178, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Fish Pen Registration (Business Permit)',
      icon: Icons.water,
      bgColor: Color.fromRGBO(254, 255, 165, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
    ServiceData(
      label: 'Issuance of Certification for Local Transport Permit',
      icon: Icons.receipt_long,
      bgColor: Color.fromRGBO(255, 190, 160, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1.0),
    ),
  ];

  // Office of the City Planning and Development Coordinato Section
  static const List<ServiceData> officeCityPlanningDevCoor = [
    ServiceData(
      label: 'Issuance of Certification for Local Transport Permit',
      icon: Icons.receipt_long,
      bgColor: Color.fromRGBO(250, 255, 175, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Issuance of Locational Clearance for Business Permit',
      icon: Icons.business,
      bgColor: Color.fromRGBO(255, 157, 157, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Issuance of Locational Clearance for Building Permit',
      icon: Icons.apartment,
      bgColor: Color.fromRGBO(252, 178, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Issuance of Development Permit',
      icon: Icons.architecture,
      bgColor: Color.fromRGBO(174, 255, 241, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Issuance of Certificate on Zoning Classification',
      icon: Icons.map,
      bgColor: Color.fromRGBO(255, 167, 167, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Assistance to Researchers/Students (Online/Walk-in)',
      icon: Icons.school,
      bgColor: Color.from(alpha: 1, red: 0.741, green: 1, blue: 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
  ];

     // City Human Settlements and Livelihood Office Section
  static const List<ServiceData> officecCityHumanSettlementsLivelihood = [
    ServiceData(
      label: 'Submission of HOA Registration Requirements (Assistance)',
      icon: Icons.home_work,
      bgColor: Color.fromRGBO(162, 207, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),

    ServiceData(
      label: 'Submission of HOA Requirements for Annual Updating (Assistance)',
      icon: Icons.update,
      bgColor: Color.fromRGBO(255, 249, 168, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),

    ServiceData(
      label: 'Submission of Complaint Letter (Assistance)',
      icon: Icons.report,
      bgColor: Color.fromRGBO(255, 202, 219, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),

    ServiceData(
      label: 'Submission of Request for HOA Election Committee Orientation (Assistance)',
      icon: Icons.groups,
      bgColor: Color.fromRGBO(193, 255, 180, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
  ];

  // Office of the City Budget Officer Section
    static const List<ServiceData> officeCityBudgetOfficer = [
    ServiceData(
      label: 'Issuance of Obligation Slip',
      icon: Icons.account_balance,
      bgColor: Color.fromRGBO(176, 255, 169, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
  ];

  // Office of the City General Services Officer Section
  static const List<ServiceData> officeCityGeneralServicesOfficer = [
    ServiceData(
      label: 'Procurement Control Procedure',
      icon: Icons.inventory,
      bgColor: Color.fromRGBO(203, 255, 173, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),

    ServiceData(
      label: 'Securing OR CR and Government Vehicle Coverage',
      icon: Icons.directions_car,
      bgColor: Color.fromRGBO(236, 162, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),

    ServiceData(
      label: 'Tagging and Inventory of PPE',
      icon: Icons.qr_code,
      bgColor: Color.fromRGBO(245, 253, 170, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),

    ServiceData(
      label: 'Disposal of Unserviceable Properties',
      icon: Icons.delete,
      bgColor: Color.fromRGBO(255, 170, 170, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),

    ServiceData(
      label: 'Maintenance Control Procedure',
      icon: Icons.build,
      bgColor: Color.fromRGBO(170, 255, 229, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
  ];

    // Office of the City Health Officer Section
    static const List<ServiceData> officeCityHealthOfficer = [
    ServiceData(
      label: 'Issuance of Certificate of Potability',
      icon: Icons.water_drop,
      bgColor: Color.fromRGBO(156, 204, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),

    ServiceData(
      label: 'Post Inspection of Business Establishments',
      icon: Icons.search,
      bgColor: Color.fromRGBO(255, 236, 175, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),

    ServiceData(
      label: 'Issuance of Health Card/Health Certificate',
      icon: Icons.health_and_safety,
      bgColor: Color.fromRGBO(255, 161, 161, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
  ];

  // City Health Office II Section 
    static const List<ServiceData> officeCityHealthOfficerII = [
    ServiceData(
      label: 'Animal Bite Treatment Services',
      icon: Icons.pets,
      bgColor: Color.fromRGBO(177, 255, 219, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Dental Services',
      icon: Icons.medical_services,
      bgColor: Color.fromRGBO(255, 211, 170, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'TB Dots Services',
      icon: Icons.coronavirus,
      bgColor: Color.fromRGBO(177, 255, 188, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Adolescent Health and Development Services',
      icon: Icons.child_care,
      bgColor: Color.fromRGBO(234, 244, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Child Care and Nutrition Services',
      icon: Icons.restaurant,
      bgColor: Color.fromRGBO(255, 169, 236, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Availment of E-Konsulta Package',
      icon: Icons.smartphone,
      bgColor: Color.fromRGBO(255, 175, 175, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Family Planning Services',
      icon: Icons.favorite,
      bgColor: Color.fromRGBO(255, 231, 166, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Laboratory Services',
      icon: Icons.biotech,
      bgColor: Color.fromRGBO(146, 198, 253, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Issuance of Medical Certificate',
      icon: Icons.description,
      bgColor: Color.fromRGBO(185, 255, 167, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Out Patient Services - DM/HPN',
      icon: Icons.local_hospital,
      bgColor: Color.fromRGBO(255, 153, 153, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Pharmacy Services',
      icon: Icons.medication,
      bgColor: Color.fromRGBO(255, 250, 176, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Vector Borne Disease Program',
      icon: Icons.bug_report,
      bgColor: Color.fromRGBO(248, 166, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Mental Health Services',
      icon: Icons.psychology,
      bgColor: Color.fromRGBO(201, 255, 206, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Drug Dependency Examination',
      icon: Icons.healing,
      bgColor: Color.fromRGBO(169, 255, 243, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
  ];

  // City Health Office II- Biñan Birthing Home Section
    static const List<ServiceData> officeCityHealthOfficerIIBirthingHome = [
    ServiceData(
      label: 'Antenatal Care Services',
      icon: Icons.pregnant_woman,
      bgColor: Color.fromRGBO(165, 255, 235, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Normal Spontaneous Delivery Services',
      icon: Icons.baby_changing_station,
      bgColor: Color.fromRGBO(238, 226, 157, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Newborn Screening Test Services',
      icon: Icons.health_and_safety,
      bgColor: Color.fromRGBO(255, 184, 214, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
  ];

    //City Disaster Risk Reduction and Management Office Section
    static const List<ServiceData> officeCDRRM = [
    ServiceData(
      label: 'Emergency and Medical Assistance',
      icon: Icons.emergency,
      bgColor: Color.fromRGBO(205, 255, 172, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Heavy Equipment Assistance and Clearing Operations',
      icon: Icons.construction,
      bgColor: Color.fromRGBO(255, 166, 166, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'CCTV Record Review',
      icon: Icons.videocam,
      bgColor: Color.fromRGBO(177, 237, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Payment for the Apprehension Violation',
      icon: Icons.payment,
      bgColor: Color.fromRGBO(255, 167, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Payment for Truck Ban Exception Sticker (6-8 wheelers only)',
      icon: Icons.local_shipping,
      bgColor: Color.fromRGBO(201, 255, 188, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
  ];

  //Public Order & Safety Office Section
    static const List<ServiceData> officePublicOrderAndSafety = [
    ServiceData(
      label: 'Payment for the Apprehension Violation',
      icon: Icons.gavel,
      bgColor: Color.fromRGBO(150, 239, 255, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
    ServiceData(
      label: 'Payment for Truck Ban Exception Sticker (6-8 wheelers only)',
      icon: Icons.local_shipping,
      bgColor: Color.fromRGBO(255, 160, 226, 1),
      iconColor: Color.fromRGBO(32, 87, 206, 1),
    ),
  ];
}