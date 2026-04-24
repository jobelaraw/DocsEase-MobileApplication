// info_data.dart

import 'info_model.dart';

class ServiceRepo {
  static final Map<String, ServiceDetail> _allServices = {

    // New Business Application
    'New Business Application': ServiceDetail(
      title: 'New Business Application',
      description: 'Standard application process for new small-to-medium enterprise operational permits within the city jurisdiction',
      tabs: [
        ServiceTab(
          name: 'Walk-In',
          requirements: [
            RequirementItem(
              title: 'BPLO FORM 001-2: Application Form For Business Permit',
              secureAt: 'Business Permit and Licensing Office',
            ),
            RequirementItem(
              title: 'Occupancy Permit (if applicable)',
              secureAt: 'City Engineering Office',
            ),
            RequirementItem(
              title: 'DTI Business Name Registration for Sole Proprietor SEC Registration for Corporation CDA Registration',
              secureAt: 'Department of Trade and Industry Securities and Exchange Commission Cooperative Development Authority',
            ),
            RequirementItem(
              title: 'Vicinity Map/ Location Sketch',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'Printed picture of business (inside, outside, front)',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'Barangay Micro Business Enterprise Certificate (if applicable)',
              secureAt: 'Barangay Hall',
            ),
            RequirementItem(
              title: 'Lease of Contract (if applicable)',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'For representatives: Authorization Letter / Special Power Of Attorney / Board Resolution / Secretary Certificate / Photocopy Of Valid Id',
              secureAt: 'Client',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Application and Assessment',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall submit the requirements and accomplish the Application Form for Business Permit.',
              fee: 'None',
              processingTime: '50 minutes',
              personsInCharge: [
                'Claribel Bautista',
                'Nessther Almenanza',
                'Zyra kaye Castillo',
                'Michelle Maramag',
                'Rosemarie Umali',
              ],
            ),
            ServiceStep(
              title: 'Payment',
              office: 'City Treasurer\'s Office',
              instruction: 'Shall pay for the amount indicated in the Tax Order of Payment and Community Tax Certificate for the business.',
              fee: 'Based on the Revised Revenue Code (2016) City of Biñan & City Ordinance No. 1-A 2022',
              processingTime: '50 minutes',
              personsInCharge: ['CTO Personnel'],
            ),
            ServiceStep(
              title: 'Release',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall sign the Business Permit Releasing Logbook, and receive Business Permit.',
              fee: 'None',
              processingTime: '50 minutes',
              personsInCharge: [
                'ABC, BFP, CENRO,',
                'CHO, CPDO, CEO,',
                'BCHATO, CVO',
                'Jerrold Peter Samonte',
                'Arnel Ibarbia',
                'Cynthia Maranan',
              ],
            ),
          ],
        ),
        ServiceTab(
          name: 'Online',
          requirements: [
            RequirementItem(
              title: 'BPLO FORM 001-2: Application Form For Business Permit',
              secureAt: 'Business Permit and Licensing Office',
            ),
            RequirementItem(
              title: 'Occupancy Permit (if applicable)',
              secureAt: 'City Engineering Office',
            ),
            RequirementItem(
              title: 'DTI Business Name Registration for Sole Proprietor SEC Registration for Corporation CDA Registration',
              secureAt: 'Department of Trade and Industry Securities and Exchange Commission Cooperative Development Authority',
            ),
            RequirementItem(
              title: 'Vicinity Map/ Location Sketch',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'Printed picture of business (inside, outside, front)',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'Barangay Micro Business Enterprise Certificate (if applicable)',
              secureAt: 'Barangay Hall',
            ),
            RequirementItem(
              title: 'Lease of Contract (if applicable)',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'For representatives: Authorization Letter / Special Power Of Attorney / Board Resolution / Secretary Certificate / Photocopy Of Valid Id',
              secureAt: 'Client',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Pay and Release',
              office: 'binanicitybusinesspermit.online',
              instruction: 'Apply using the website, submit requirements, and pay corresponding taxes. Electronic copy of permit will be available for download. *Delivery of permits and clearances is optional.',
              fee: 'Based on the Revised Revenue Code (2016)',
              processingTime: '2 hrs 30 mins',
              personsInCharge: ['BPLO Online Staff'],
            ),
          ],
        ),
      ],
      location: '1st Floor, City Hall Building, Brgy. Zapote, City of Biñan, Laguna',
      duration: '2 hrs and 30 mins',
      contactPhone: '(049)513-5084',
      contactEmail: 'bplo@binan.gov.ph',
      cost: 'None',
    ),

    // Renewal of Business Application
    'Renewal of Business Application': ServiceDetail(
      title: 'Renewal of Business Application',
      description: 'Provide assistance to business owners to apply for renewal of business permit.',
      tabs: [
        ServiceTab(
          name: 'Walk-In',
          requirements: [
            RequirementItem(
              title: 'BPLO FORM 001-2: Application Form For Business Permit',
              secureAt: 'Business Permit and Licensing Office',
            ),
            RequirementItem(
              title: 'Basis for Computation of Gross Sales / Annual Income Tax Returns',
              secureAt: 'Bureau of Internal Revenue',
            ),
            RequirementItem(
              title: 'For establishments with branches: Certificate of Breakdown of Sales per Branch',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'For establishments with various lines of business: Certificate of Breakdown of Sales per line of business',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'For representatives: Authorization Letter / Special Power Of Attorney / Board Resolution / Secretary Certificate / Photocopy Of Valid Id',
              secureAt: 'Client',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Application and Assessment',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall submit the requirements and accomplish the Application Form for Business Permit.',
              fee: 'None',
              processingTime: '50 minutes',
              personsInCharge: ['Claribel Bautista', 'Nessther Almenanza'],
            ),
            ServiceStep(
              title: 'Payment',
              office: 'City Treasurer\'s Office',
              instruction: 'Shall pay for the amount indicated in the Tax Order of Payment and Community Tax Certificate for the business.',
              fee: 'Based on the Revised Revenue Code (2016) City of Biñan',
              processingTime: '50 minutes',
              personsInCharge: ['CTO Personnel'],
            ),
            ServiceStep(
              title: 'Release',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall sign the Business Permit Releasing Logbook, and receive Business Permit.',
              fee: 'None',
              processingTime: '50 minutes',
              personsInCharge: ['Rosemarie Umali', 'Cynthia Maranan'],
            ),
          ],
        ),
        ServiceTab(
          name: 'Hybrid',
          requirements: [
            RequirementItem(
              title: 'BPLO FORM 001-2: Application Form For Business Permit',
              secureAt: 'Business Permit and Licensing Office',
            ),
            RequirementItem(
              title: 'Basis for Computation of Gross Sales / Annual Income Tax Returns',
              secureAt: 'Bureau of Internal Revenue',
            ),
            RequirementItem(
              title: 'For representatives: Authorization Letter / Special Power Of Attorney / Board Resolution / Secretary Certificate',
              secureAt: 'Client',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Pay and Release',
              office: 'binanicitybusinesspermit.online',
              instruction: 'Apply using the website, submit requirements, and pay corresponding taxes. Electronic copy of permit will be available for download. *Delivery of permits and clearances is optional.',
              fee: 'Based on the Revised Revenue Code (2016)',
              processingTime: '2 hrs 30 mins',
              personsInCharge: ['BPLO Online Staff'],
            ),
          ],
        ),
      ],
      location: '1st Floor, City Hall Building, Brgy. Zapote, City of Biñan, Laguna',
      duration: '2 hrs and 30 mins',
      contactPhone: '(049)513-5084',
      contactEmail: 'bplo@binan.gov.ph',
      cost: 'Based on the Revised Revenue Code (2016) City of Biñan',
    ),

    // Retirement of Business
    'Retirement of Business': ServiceDetail(
      title: 'Retirement of Business',
      description: 'Provide assistance to businesses who will terminate their businesses permanently.',
      tabs: [
        ServiceTab(
          name: 'Walk-In',
          requirements: [
            RequirementItem(
              title: 'BPLO-024-1 Application Form for Retirement of Business',
              secureAt: 'Business Permit and Licensing Office',
            ),
            RequirementItem(
              title: 'Request Letter for Closure',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'Barangay Clearance for Closure',
              secureAt: 'Barangay Hall',
            ),
            RequirementItem(
              title: 'Income Tax Return or any basis for the computation of Gross Sales',
              secureAt: 'Bureau of Internal Revenue',
            ),
            RequirementItem(
              title: 'Business Retirement Inspection Report',
              secureAt: 'Business Permit and Licensing Office',
            ),
            RequirementItem(
              title: 'Latest Business Permit',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'For representatives: Authorization Letter / Special Power Of Attorney / Board Resolution / Secretary Certificate / Photocopy Of Valid Id',
              secureAt: 'Client',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Application',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall submit the requirements notarized Application Form for Business Retirement.',
              fee: 'None',
              processingTime: '30 minutes',
              personsInCharge: ['Rosemarie Umali'],
            ),
            ServiceStep(
              title: 'Payment',
              office: 'City Treasurer\'s Office',
              instruction: 'Shall pay for the amount indicated in the Tax Order of Payment.',
              fee: 'Based on the Revised Revenue Code (2016)',
              processingTime: '30 minutes',
              personsInCharge: ['CTO Personnel'],
            ),
            ServiceStep(
              title: 'Release',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall sign the Certificate of Retirement Releasing Logbook, and receive Certificate of Retirement.',
              fee: 'None',
              processingTime: '30 minutes',
              personsInCharge: ['Rosemarie Umali'],
            ),
          ],
        ),
      ],
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 hr 30 minutes',
      contactPhone: '(049)513-5084',
      contactEmail: 'bplo@binan.gov.ph',
      cost: 'Based on the Revised Revenue Code (2016) City of Biñan',
    ),

    // Special Permit
    'Special Permit': ServiceDetail(
      title: 'Special Permit',
      description: 'Provide assistance for application of Special Permit for bazaars, tarpaulins, contractors, and events.',
      tabs: [
        ServiceTab(
          name: 'Walk-In',
          requirements: [
            RequirementItem(
              title: 'BPLO-006-2 Special Permit Application Form',
              secureAt: 'Business Permit and Licensing Office',
            ),
            RequirementItem(
              title: 'Request Letter (addressed to the City Mayor, endorsed to BPLO)',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'For Tarpaulin Posting: Barangay Clearance For Tarpaulin',
              secureAt: 'Barangay Hall',
            ),
            RequirementItem(
              title: 'For Contractor: Notice To Proceed or any document indicating Total Contract Price, SEC/DTI Registration',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'For Sale Of Fireworks: Permit to Sell Firecrackers and Pyrotechnic Devices',
              secureAt: 'Client',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Application',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall submit the requirements and accomplish the Special Permit Application Form.',
              fee: 'None',
              processingTime: '30 minutes',
              personsInCharge: ['Zyra Kaye Castillo'],
            ),
            ServiceStep(
              title: 'Payment',
              office: 'City Treasurer\'s Office',
              instruction: 'Shall pay for the amount indicated in the Special Permit Tax Order of Payment.',
              fee: 'Based on the Revised Revenue Code (2016)',
              processingTime: '30 minutes',
              personsInCharge: ['CTO Personnel'],
            ),
            ServiceStep(
              title: 'Release',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall provide photocopies of requirements, sign the Special Permit Releasing Logbook, and receive Special Permit.',
              fee: 'None',
              processingTime: '30 minutes',
              personsInCharge: ['Zyra Kaye Castillo'],
            ),
          ],
        ),
      ],
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 hr 30 minutes',
      contactPhone: '(049)513-5084',
      contactEmail: 'bplo@binan.gov.ph',
      cost: 'Based on the Revised Revenue Code (2016) City of Biñan',
    ),

    // Certificate of No Record
    'Certificate of No Record': ServiceDetail(
      title: 'Certificate of No Record',
      description: 'Provide assistance to the public who need to get Certificate of No Record.',
      tabs: [
        ServiceTab(
          name: 'Walk-In',
          requirements: [
            RequirementItem(
              title: 'Certificate of Residency / Certificate of Indigency',
              secureAt: 'Barangay Hall',
            ),
            RequirementItem(
              title: 'Certificate of Indigency',
              secureAt: 'Barangay Hall',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Application',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall submit the requirements.',
              fee: 'None',
              processingTime: '15 minutes',
              personsInCharge: ['Nessther Almenanza'],
            ),
            ServiceStep(
              title: 'Payment',
              office: 'City Treasurer\'s Office',
              instruction: 'Shall pay certification fee.',
              fee: 'P 150.00',
              processingTime: '15 minutes',
              personsInCharge: ['CTO Personnel'],
            ),
            ServiceStep(
              title: 'Release',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall sign the Certificate of No Record Releasing Logbook, and receive Certificate of No Record.',
              fee: 'None',
              processingTime: '15 minutes',
              personsInCharge: ['Nessther Almenanza'],
            ),
          ],
        ),
      ],
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 hr 30 minutes',
      contactPhone: '(049)513-5084',
      contactEmail: 'bplo@binan.gov.ph',
      cost: 'P 150.00',
    ),

    // Permit Update Transactions
    'Permit Update Transactions': ServiceDetail(
      title: 'Permit Update Transactions',
      description: 'Provide assistance to the business establishments who have amendments in their business name / address / owner.',
      tabs: [
        ServiceTab(
          name: 'Walk-In',
          requirements: [
            RequirementItem(
              title: 'Request Letter, indicating purpose of transaction',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'Original Business Permit (to be surrendered)',
              secureAt: 'Client',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Application',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall submit the requirements.',
              fee: 'None',
              processingTime: '15 minutes',
              personsInCharge: ['Nessther Almenanza'],
            ),
            ServiceStep(
              title: 'Payment',
              office: 'City Treasurer\'s Office',
              instruction: 'Shall pay permit update fee.',
              fee: 'Change Name: ₱200.00\nChange Address: ₱200.00',
              processingTime: '15 minutes',
              personsInCharge: ['CTO Personnel'],
            ),
            ServiceStep(
              title: 'Release',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall provide photocopies of requirement and receive updated Business Permit.',
              fee: 'None',
              processingTime: '15 minutes',
              personsInCharge: ['Nessther Almenanza'],
            ),
          ],
        ),
      ],
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 hr 30 minutes',
      contactPhone: '(049)513-5084',
      contactEmail: 'bplo@binan.gov.ph',
      cost: 'Change Name: ₱200.00\nChange Address: ₱200.00',
    ),

    // Certificate of Business Status
    'Certificate of Business Status': ServiceDetail(
      title: 'Certificate of Business Status',
      description: 'Provide assistance to the public who need to get Certificate of Business Status.',
      tabs: [
        ServiceTab(
          name: 'Walk-In',
          requirements: [
            RequirementItem(
              title: 'Request Letter',
              secureAt: 'Client',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Application',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall submit the requirements.',
              fee: 'None',
              processingTime: '15 minutes',
              personsInCharge: ['Marvic Vasquez'],
            ),
            ServiceStep(
              title: 'Payment',
              office: 'City Treasurer\'s Office',
              instruction: 'Shall pay certification fee.',
              fee: 'P 150.00',
              processingTime: '15 minutes',
              personsInCharge: ['CTO Personnel'],
            ),
            ServiceStep(
              title: 'Release',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall sign the Certificate of Business Status Releasing Logbook, and receive Certificate of Business Status.',
              fee: 'None',
              processingTime: '15 minutes',
              personsInCharge: ['Marvic Vasquez'],
            ),
          ],
        ),
      ],
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 hr 30 minutes',
      contactPhone: '(049)513-5084',
      contactEmail: 'bplo@binan.gov.ph',
      cost: 'P 150.00',
    ),

    // Complaints and Violations
    'Complaints and Violations': ServiceDetail(
      title: 'Complaints and Violations',
      description: 'Provide assistance to the public who need to file complaints or violations.',
      tabs: [
        ServiceTab(
          name: 'Walk-In',
          requirements: [
            RequirementItem(
              title: 'BPLO-007-2 Customer Complaint Form',
              secureAt: 'Business Permit and Licensing Office',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Filing of Complaint',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall submit filled out Customer Complaint Form.',
              fee: 'None',
              processingTime: '30 minutes',
              personsInCharge: ['Marvic Vasquez'],
            ),
          ],
        ),
      ],
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 hr 30 minutes',
      contactPhone: '(049)513-5084',
      contactEmail: 'bplo@binan.gov.ph',
      cost: 'None',
    ),

    // Construction Permits Application
    'Construction Permits Application': ServiceDetail(
      title: 'Construction Permits Application',
      description: 'Application for Building Permit, FSEC and Zoning/Locational Clearance.',
      tabs: [
        ServiceTab(
          name: 'Walk-In',
          requirements: [
            RequirementItem(
              title: 'Unified Application form for Building Permit, FSEC and Zoning/Locational Clearance',
              secureAt: 'Office of the Building Official',
            ),
            RequirementItem(
              title: 'NBC Forms (duly Accomplished Application Forms)',
              secureAt: 'Office of the Building Official',
            ),
            RequirementItem(
              title: 'Lot Plan (Signed & Sealed by Geodetic Engineer)',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'Building Plans (Signed & Sealed by Professionals)',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'Notarized Bill of Materials (Signed & sealed by professionals)',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'Transfer Certificate of Title',
              secureAt: 'Registry of Deeds',
            ),
            RequirementItem(
              title: 'Tax Declaration & Tax Receipt',
              secureAt: 'City Assessor\'s Office',
            ),
            RequirementItem(
              title: 'Barangay Clearance for Construction with no objection',
              secureAt: 'Barangay Hall',
            ),
            RequirementItem(
              title: 'Community Tax Certificate',
              secureAt: 'City Treasurer\'s Office',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Submit Requirements',
              office: 'Office of the Building Official',
              instruction: 'The applicant submits the filled-up Unified Application Form for Building Permit, FSEC and Zoning/Locational Clearance together with the requirements.',
              fee: 'None',
              processingTime: '30 minutes',
              personsInCharge: ['CPDO Staff'],
            ),
            ServiceStep(
              title: 'Payment',
              office: 'City Treasurer\'s Office',
              instruction: 'The applicant receives the Order of Payment and pays at the City Treasurer\'s Office.',
              fee: 'Based on NBCP provisions',
              processingTime: '30 minutes',
              personsInCharge: ['CTO Personnel'],
            ),
            ServiceStep(
              title: 'Submit the Official Receipt',
              office: 'Office of the Building Official',
              instruction: 'The Applicant submits the Official Receipt then signs the logbook signifying the receipt of the Building Permits, Clearances and other documents.',
              fee: 'None',
              processingTime: '30 minutes',
              personsInCharge: ['CPDO Staff'],
            ),
          ],
        ),
      ],
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 hr 30 minutes',
      contactPhone: '(049)513-5084',
      contactEmail: 'obo@binan.gov.ph',
      cost: 'Permit fees are based on the provisions stated in the NBCP',
    ),

    // Certificate of Final Electrical Inspection (CFEI) Application
    'Certificate of Final Electrical Inspection (CFEI) Application': ServiceDetail(
      title: 'Certificate of Final Electrical Inspection (CFEI) Application',
      description: 'Application for Certificate of Final Electrical Inspection.',
      tabs: [
        ServiceTab(
          name: 'Walk-In',
          requirements: [
            RequirementItem(
              title: 'For Temporary Connection: Approved Building Permit',
              secureAt: 'Office of the Building Official',
            ),
            RequirementItem(
              title: 'For Temporary Connection: Approved Electrical Permit Contract of Form',
              secureAt: 'Office of the Building Official',
            ),
            RequirementItem(
              title: 'For Temporary Connection: Yellow Card issued by Service Provider',
              secureAt: 'Service Provider',
            ),
            RequirementItem(
              title: 'Permanent Connection: Occupancy Permit',
              secureAt: 'Office of the Building Official',
            ),
            RequirementItem(
              title: 'Permanent Connection: Electrical Inspection Form signed by the owner/applicant',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'Permanent Connection: Yellow Card issued by Service Provider',
              secureAt: 'Service Provider',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Submit Requirements',
              office: 'Office of the Building Official',
              instruction: 'The applicant submits the requirements to assigned staff and waits for the schedule for inspection.',
              fee: 'None',
              processingTime: '30 minutes',
              personsInCharge: ['OBO Staff'],
            ),
            ServiceStep(
              title: 'Payment',
              office: 'City Treasurer\'s Office',
              instruction: 'After inspection, the applicant submits the complete requirements and receives the Order of Payment and proceeds to the City Treasurer\'s Office.',
              fee: 'Based on IRR of NBCP',
              processingTime: '30 minutes',
              personsInCharge: ['CTO Personnel'],
            ),
            ServiceStep(
              title: 'Submit the Official Receipt',
              office: 'Office of the Building Official',
              instruction: 'The applicant shall submit the Official Receipt to the Office of the Building Official and receives the approved CFEI.',
              fee: 'None',
              processingTime: '30 minutes',
              personsInCharge: ['OBO Staff'],
            ),
          ],
        ),
      ],
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 Day',
      contactPhone: '(049)513-5084',
      contactEmail: 'obo@binan.gov.ph',
      cost: 'Permit fees are based on the IRR of the NBCP',
    ),

    // Issuance of Certificate of Annual Inspection
    'Issuance of Certificate of Annual Inspection': ServiceDetail(
      title: 'Issuance of Certificate of Annual Inspection',
      description: 'Application for Certificate of Annual Inspection.',
      tabs: [
        ServiceTab(
          name: 'Renewal of Business Permit',
          requirements: [
            RequirementItem(
              title: 'Duly accomplished business permit application form',
              secureAt: 'Office of the Building Official',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Submit Requirements',
              office: 'Office of the Building Official',
              instruction: 'The applicant submits the duly accomplished application form.',
              fee: 'None',
              processingTime: '30 minutes',
              personsInCharge: ['OBO Staff'],
            ),
            ServiceStep(
              title: 'Payment',
              office: 'City Treasurer\'s Office',
              instruction: 'The applicant receives the Order of Payment and proceeds to the City Treasurer\'s Office for issuance of Official Receipt.',
              fee: 'Based on IRR of NBCP',
              processingTime: '30 minutes',
              personsInCharge: ['CTO Personnel'],
            ),
            ServiceStep(
              title: 'Submit the Official Receipt',
              office: 'Office of the Building Official',
              instruction: 'The applicant shall submit the Official Receipt to the Office of the Building Official and receives the approved business permit.',
              fee: 'None',
              processingTime: '30 minutes',
              personsInCharge: ['OBO Staff'],
            ),
          ],
        ),
        ServiceTab(
          name: 'New Business Permit',
          requirements: [
            RequirementItem(
              title: 'Duly accomplished business permit application form',
              secureAt: 'Office of the Building Official',
            ),
            RequirementItem(
              title: 'Certificate of Occupancy',
              secureAt: 'Office of the Building Official',
            ),
            RequirementItem(
              title: 'Sketch of Location',
              secureAt: 'Client',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Submit Requirements',
              office: 'Office of the Building Official',
              instruction: 'The applicant submits the duly accomplished application form.',
              fee: 'None',
              processingTime: '30 minutes',
              personsInCharge: ['OBO Staff'],
            ),
            ServiceStep(
              title: 'Payment',
              office: 'City Treasurer\'s Office',
              instruction: 'The applicant receives the Order of Payment and proceeds to the City Treasurer\'s Office for issuance of Official Receipt.',
              fee: 'Based on IRR of NBCP',
              processingTime: '30 minutes',
              personsInCharge: ['CTO Personnel'],
            ),
            ServiceStep(
              title: 'Submit the Official Receipt',
              office: 'Office of the Building Official',
              instruction: 'The applicant shall submit the Official Receipt to the Office of the Building Official and receives the approved business permit.',
              fee: 'None',
              processingTime: '30 minutes',
              personsInCharge: ['OBO Staff'],
            ),
          ],
        ),
      ],
      location: 'Ground Floor, Biñan City Hall',
      duration: '2 hrs',
      contactPhone: '(049)513-5084',
      contactEmail: 'obo@binan.gov.ph',
      cost: 'Permit fees are based on the IRR of the NBCP',
    ),

    // Certificate of Occupancy Application
    'Certificate of Occupancy Application': ServiceDetail(
      title: 'Certificate of Occupancy Application',
      description: 'Application for Certificate of Occupancy.',
      tabs: [
        ServiceTab(
          name: 'Walk-In',
          requirements: [
            RequirementItem(
              title: 'Certificate of Completion Form',
              secureAt: 'Office of the Building Official',
            ),
            RequirementItem(
              title: 'Approved Building Permit',
              secureAt: 'Office of the Building Official',
            ),
            RequirementItem(
              title: 'Approved Electrical Permit',
              secureAt: 'Office of the Building Official',
            ),
            RequirementItem(
              title: 'Approved Plumbing Permit',
              secureAt: 'Office of the Building Official',
            ),
            RequirementItem(
              title: 'Fire Safety Inspection Certificate (FSIC)',
              secureAt: 'Bureau of Fire Protection',
            ),
            RequirementItem(
              title: 'Three (3) copies of duly notarized Certificate of Completion signed by the owner and licensed Architect/Engineer',
              secureAt: 'Client',
            ),
            RequirementItem(
              title: 'Captured Photograph of the completed structure showing front, sides and rear areas',
              secureAt: 'Client',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Submit Requirements',
              office: 'Office of the Building Official',
              instruction: 'The applicant submits the requirements and accomplished form to assigned staff and waits for the schedule of inspection.',
              fee: 'None',
              processingTime: '30 minutes',
              personsInCharge: ['OBO Staff'],
            ),
            ServiceStep(
              title: 'Payment',
              office: 'City Treasurer\'s Office',
              instruction: 'If documents are complete, the applicant is issued the Order of Payment and proceeds to the City Treasurer\'s Office for Official Receipt.',
              fee: 'Based on NBCP provisions',
              processingTime: '30 minutes',
              personsInCharge: ['CTO Personnel'],
            ),
            ServiceStep(
              title: 'Submit the Official Receipt',
              office: 'Office of the Building Official',
              instruction: 'The applicant shall submit the Official Receipt to the Office of the Building Official and receives the approved Certificate of Occupancy.',
              fee: 'None',
              processingTime: '30 minutes',
              personsInCharge: ['OBO Staff'],
            ),
          ],
        ),
      ],
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 hr 30 minutes',
      contactPhone: '(049)513-5084',
      contactEmail: 'obo@binan.gov.ph',
      cost: 'Permit fees are based on the provisions stated in the NBCP',
    ),

    // Project Preparation
    'Project Preparation': ServiceDetail(
      title: 'Project Preparation',
      description: 'Preparation of Program of Works and Detailed Plans.',
      tabs: [
        ServiceTab(
          name: 'Walk-In',
          requirements: [
            RequirementItem(
              title: 'Request letter with approval of the City Mayor',
              secureAt: 'Office of the City Mayor',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Submit Request Letter',
              office: 'Office of the City Engineer',
              instruction: 'Submit the request letter to the Office of the Mayor.',
              fee: 'None',
              processingTime: '10 Days',
              personsInCharge: ['Engineering Staff'],
            ),
          ],
        ),
      ],
      location: 'Ground Floor, Biñan City Hall',
      duration: '10 Days',
      contactPhone: '(049)513-5084',
      contactEmail: 'engineering@binan.gov.ph',
      cost: 'None',
    ),

    // Project Implementation
    'Project Implementation': ServiceDetail(
      title: 'Project Implementation',
      description: 'Implementation, monitoring and processing of payment for infrastructure projects.',
      tabs: [
        ServiceTab(
          name: 'Walk-In',
          requirements: [
            RequirementItem(
              title: 'Approved Program of Works and detailed plan, copy of bid proposal from winning bidder, Notice of Award from the BAC, Contract and Notice to proceed',
              secureAt: 'Office of the City Engineer',
            ),
            RequirementItem(
              title: 'For progress billing or full payment – List of Requirements for Partial/Full Payment',
              secureAt: 'Office of the City Engineer',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Request',
              office: 'Office of the City Engineer',
              instruction: 'Request for site inspection with Engineering staff.',
              fee: 'None',
              processingTime: '1 Day',
              personsInCharge: ['Engineering Staff'],
            ),
            ServiceStep(
              title: 'Payment',
              office: 'Office of the City Engineer',
              instruction: 'Request for partial/full payment.',
              fee: 'None',
              processingTime: '1 Day',
              personsInCharge: ['Engineering Staff'],
            ),
            ServiceStep(
              title: 'Submit Requirements',
              office: 'Office of the City Engineer',
              instruction: 'After submission of complete requirements.',
              fee: 'None',
              processingTime: '1 Day',
              personsInCharge: ['Engineering Staff'],
            ),
          ],
        ),
      ],
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 Day',
      contactPhone: '(049)513-5084',
      contactEmail: 'engineering@binan.gov.ph',
      cost: 'None',
    ),

    // Repair and Maintenance of Streetlights
    'Repair and Maintenance of Streetlights': ServiceDetail(
      title: 'Repair and Maintenance of Streetlights',
      description: 'Repair and maintenance of streetlights in the various barangays.',
      tabs: [
        ServiceTab(
          name: 'Walk-In',
          requirements: [
            RequirementItem(
              title: 'Request letter from barangay',
              secureAt: 'Barangay Hall',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Request',
              office: 'Office of the City Engineer',
              instruction: 'Submit request letter to the Barangay Captain.',
              fee: 'None',
              processingTime: '1 Day',
              personsInCharge: ['Engineering Staff'],
            ),
          ],
        ),
      ],
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 Day',
      contactPhone: '(049)513-5084',
      contactEmail: 'engineering@binan.gov.ph',
      cost: 'None',
    ),

    // Project Preparation and Implementation for Barangays
    'Project Preparation and Implementation for Barangays': ServiceDetail(
      title: 'Project Preparation and Implementation for Barangays',
      description: 'Preparation of Program of Works and Detailed Plans, implementation and monitoring.',
      tabs: [
        ServiceTab(
          name: 'Walk-In',
          requirements: [
            RequirementItem(
              title: 'Request letter with approval of the City Mayor',
              secureAt: 'Office of the City Mayor',
            ),
          ],
          steps: [
            ServiceStep(
              title: 'Submit the Request Letter',
              office: 'Office of the City Engineer',
              instruction: 'Submit the request letter to the Office of the Mayor for approval.',
              fee: 'None',
              processingTime: '1 Day',
              personsInCharge: ['Engineering Staff'],
            ),
            ServiceStep(
              title: 'Request',
              office: 'Office of the City Engineer',
              instruction: 'Request for project implementation and monitoring.',
              fee: 'None',
              processingTime: '1 Day',
              personsInCharge: ['Engineering Staff'],
            ),
            ServiceStep(
              title: 'Payment',
              office: 'Office of the City Engineer',
              instruction: 'Request for payment.',
              fee: 'None',
              processingTime: '1 Day',
              personsInCharge: ['Engineering Staff'],
            ),
          ],
        ),
      ],
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 Day',
      contactPhone: '(049)513-5084',
      contactEmail: 'engineering@binan.gov.ph',
      cost: 'None',
    ),
  };

  static ServiceDetail getDetail(String title) {
    return _allServices[title] ?? _allServices.values.first;
  }
}