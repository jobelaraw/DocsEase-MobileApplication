import 'info_model.dart';

class ServiceRepo {
  static final Map<String, ServiceDetail> _allServices = {

    // New Business Application
    'New Business Application': ServiceDetail(
      title: 'New Business Application',
      description: 'Provide assistance to new business owners to apply for business permit.',
      tabs: [
        ServiceTab(
          name: 'Walk-in',
          requirements: [
            'BPLO FORM 001-2: Application Form For Business Permit',
            'Occupancy Permit (if applicable)',
            'DTI Business Name Registration for Sole Proprietor SEC Registration for Corporation CDA Registration',
            'Vicinity Map/ Location Sketch',
            'Printed picture of business (inside, outside, front)',
            'Barangay Micro Business Enterprise Certificate (if applicable)',
            'Lease of Contract (if applicable)',
            'For representatives: *Sole Proprietor—Authorization Letter/ Special Power Of Attorney *Partnership/ Corporation—Board Resolution / Secretary Certificate *Photocopy Of Valid Id From Owner And Representative Other applicable regulatory requirements'
          ],
          steps: [
            ServiceStep(
              title: 'Application and Assessment ',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall submit the requirements and accomplish the Application Form for Business Permit.',
            ),
            ServiceStep(
              title: 'Payment',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall pay for the amount indicated in the Tax Order of Payment and Community Tax Certificate for the business.',
            ),
            ServiceStep(
              title: 'Release',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall sign the Business Permit Releasing Logbook, and receive Business Permit.',
            ),
          ],
        ),
        ServiceTab(
          name: 'Online',
          requirements: [
            'BPLO FORM 001-2: Application Form For Business Permit',
            'Occupancy Permit (if applicable)',
            'DTI Business Name Registration for Sole Proprietor SEC Registration for Corporation CDA Registration',
            'Vicinity Map/ Location Sketch',
            'Printed picture of business (inside, outside, front)',
            'Barangay Micro Business Enterprise Certificate (if applicable)',
            'Lease of Contract (if applicable)',
            'For representatives: *Sole Proprietor—Authorization Letter/ Special Power Of Attorney *Partnership/ Corporation—Board Resolution / Secretary Certificate *Photocopy Of Valid Id From Owner And Representative Other applicable regulatory requirements',
          ],
          steps: [
            ServiceStep(
              title: 'Pay and Release',
              office: 'binancitybusinessper mit.online',
              instruction: 'Apply using the website, submit requirements, and pay corresponding taxes. Electronic copy of permit with the same level of authority as the hard copy will be available for download. *delivery of permits and clearances is optional..',
            ),
          ],
        ),
      ],
      location: '2nd Floor, Biñan City Hall',
      duration: '2 hrs and 30 mins',
      personnel: 'Claribel Bautista',
      cost: 'None',
    ),

     // Renewal of Business Application
    'Renewal of Business Application': ServiceDetail(
      title: 'Renewal of Business Application',
      description: 'Provide assistance to business owners to apply for renewal of business permit.',
      tabs: [
        ServiceTab(
          name: 'Walk-in',
          requirements: [
            'BPLO FORM 001-2: Application Form For Business Permit',
            'Basis for Computation of Gross Sales Annual Income Tax Returns of the preceding year or\n  - 1st to 3rd Quarter Income Tax Returns or\n  - 1st to 3rd Quarter Percentage Tax Returns or\n  - 1st to 3rd Quarter VAT Returns',
            'For establishments with branches: Certificate of Breakdown of Sales per Branch',
            'For establishments with various lines of business: Certificate of Breakdown of Sales per line of business',
            'For representatives: *Sole Proprietor—Authorization Letter/ Special Power Of Attorney *Partnership/ Corporation—Board Resolution / Secretary Certificate *Photocopy Of Valid Id From Owner And Representative Other applicable regulatory requirements'
          ],
          steps: [
            ServiceStep(
              title: 'Application and Assessment ',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall submit the requirements and accomplish the Application Form for Business Permit.',
            ),
            ServiceStep(
              title: 'Payment',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall pay for the amount indicated in the Tax Order of Payment and Community Tax Certificate for the business.',
            ),
            ServiceStep(
              title: 'Release',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall sign the Business Permit Releasing Logbook, and receive Business Permit.',
            ),
          ],
        ),
        ServiceTab(
          name: 'Online',
          requirements: [
            'BPLO FORM 001-2: Application Form For Business Permit',
            'Basis for Computation of Gross Sales Annual Income Tax Returns of the preceding year or\n  - 1st to 3rd Quarter Income Tax Returns or\n  - 1st to 3rd Quarter Percentage Tax Returns or\n  - 1st to 3rd Quarter VAT Returns',
            'For establishments with branches: Certificate of Breakdown of Sales per Branch',
            'For establishments with various lines of business: Certificate of Breakdown of Sales per line of business',
            'For representatives: *Sole Proprietor—Authorization Letter/ Special Power Of Attorney *Partnership/ Corporation—Board Resolution / Secretary Certificate *Photocopy Of Valid Id From Owner And Representative Other applicable regulatory requirements'
          ],
          steps: [
            ServiceStep(
              title: 'Pay and Release',
              office: 'binancitybusinessper mit.online',
              instruction: 'Apply using the website, submit requirements, and pay corresponding taxes. Electronic copy of permit with the same level of authority as the hard copy will be available for download. *delivery of permits and clearances is optional..',
            ),
          ],
        ),
      ],
      location: '2nd Floor, Biñan City Hall',
      duration: '2 hrs and 30 mins',
      personnel: 'Claribel Bautistak',
      cost: 'Based on the Revised Revenue Code (2016) City of Biñan',
    ),



    // Retirement of Business
    'Retirement of Business': ServiceDetail(
      title: 'Retirement of Business',
      description: 'Provide assistance to businesses who will terminate their businesses permanently. Persons engaged in business or undertaking in the City of Biñan or their authorized representatives.',
      tabs: [
        ServiceTab(
          name: 'Walk-in',
          requirements: [
            'BPLO-024-1 Application Form for Retirement of Business',
            'Request Letter for Closure',
            'Barangay Clearance for Closure',
            'Income Tax Return or any basis for the computation of Gross Sales',
            'Business Retirement Inspection Report',
            'Latest Business Permit',
            'For representatives: *Sole Proprietor—Authorization Letter/ Special Power Of Attorney *Partnership/ Corporation—Board Resolution / Secretary Certificate *Photocopy Of Valid Id From Owner And Representative Other applicable regulatory requirements',
          ],
          steps: [
            ServiceStep(
              title: 'Application',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall submit the requirements notarized Application Form for Business Retirement.',
            ),
            ServiceStep(
              title: 'Payment',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall pay for the amount indicated in the Tax Order of Payment.',
            ),
            ServiceStep(
              title: 'Release',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall sign the Certificate of Retirement Releasing Logbook, and receive Certificate of Retirement.',
            ),
          ],
        ),
      ], 
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 hr 30 minutes',
      personnel: 'Rosemarie Umali',
      cost: 'Based on the Revised Revenue Code (2016) City of Biñan',
    ),

    // Special Permit
    'Special Permit': ServiceDetail(
      title: 'Special Permit',
      description: 'Provide assistance for application of Special Permit for bazaars, tarpaulins, contractors, and events.',
      tabs: [
        ServiceTab(
          name: 'Walk-in',
          requirements: [
            'BPLO-006-2 Special Permit Application Form',
            'Request Letter (addressed to the City Mayor, endorsed to BPLO) ',
            'For Tarpaulin Posting Barangay Clearance For Tarpaulin',
            'For Contractor Notice To Proceed or any document indicating Total Contract Price SEC/DTI Registration',
            'For Sale Of Fireworks Permit to Sell Firecrackers and Pyrotechnic Devices Seminar on Firecrackers and Pyrotechnic Devices'
          ],
          steps: [
            ServiceStep(
              title: 'Application',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall submit the requirements and accomplish the Special Permit Application Form.',
            ),
            ServiceStep(
              title: 'Payment',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall pay for the amount indicated in the Special Permit Tax Order of Payment.',
            ),
            ServiceStep(
              title: 'Release',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall provide photocopies of requirements, sign the Special Permit Releasing Logbook, and receive Special Permit.',
            ),
          ],
        ),
      ], 
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 hr 30 minutes',
      personnel: 'Zyra Kaye Castillo',
      cost: 'Based on the Revised Revenue Code (2016) City of Biñan',
    ),

    // Certificate of No Record
    'Certificate of No Record': ServiceDetail(
      title: 'Certificate of No Record',
      description: 'Provide assistance to the public who need to get Certificate of No Record.',
      tabs: [
        ServiceTab(
          name: 'Walk-in',
          requirements: [
            'Certificate of Residency/ Certificate of Indigency ',
            'Certificate of Indigency Barangay Hall 2.'
          ],
          steps: [
            ServiceStep(
              title: 'Application',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall submit the requirements.',
            ),
            ServiceStep(
              title: 'Payment',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall pay certification fee.',
            ),
            ServiceStep(
              title: 'Release',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall sign the Certificate of No Record Releasing Logbook, and receive Certificate of No Record.',
            ),
          ],
        ),
      ], 
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 hr 30 minutes',
      personnel: 'Nessther Almenanza',
      cost: 'P 150.00',
    ),

    // Permit Update Transactions
    'Permit Update Transactions': ServiceDetail(
      title: 'Permit Update Transactions',
      description: 'Provide assistance to the business establishments who have amendments in their business name/ address/ owner.',
      tabs: [
        ServiceTab(
          name: 'Walk-in',
          requirements: [
            'Request Letter, indicating purpose of transaction',
            'Original Business Permit (to be surrendered)'
          ],
          steps: [
            ServiceStep(
              title: 'Application',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall submit the requirements.',
            ),
            ServiceStep(
              title: 'Payment',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall pay permit update fee.',
            ),
            ServiceStep(
              title: 'Release',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall provide photocopies of requirement and receive updated Business Permit.',
            ),
          ],
        ),
      ], 
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 hr 30 minutes',
      personnel: 'Nessther Almenanza',
      cost: 'Change Name: 200.00\nChange Address: 200.00',
    ),

    // Certificate of Business Status
    'Certificate of Business Status': ServiceDetail(
      title: 'Certificate of Business Status',
      description: 'Provide assistance to the public who need to get Certificate of Business Status.',
      tabs: [
        ServiceTab(
          name: 'Walk-in',
          requirements: [
            'Request Letter',
          ],
          steps: [
            ServiceStep(
              title: 'Application',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall submit the requirements.',
            ),
            ServiceStep(
              title: 'Payment',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall pay certification fee.',
            ),
            ServiceStep(
              title: 'Release',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall sign the Certificate of Business Status Releasing Logbook, and receive Certificate of Business Status.',
            ),
          ],
        ),
      ], 
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 hr 30 minutes',
      personnel: 'Marvic Vasquez',
      cost: 'P 150.00',
    ),

    // Complaints and Violations
    'Complaints and Violations': ServiceDetail(
      title: 'Complaints and Violations',
      description: 'Provide assistance to the public who need to get Certificate of Business Status.',
      tabs: [
        ServiceTab(
          name: 'Walk-in',
          requirements: [
            'BPLO-007-2 Customer Complaint Form',
          ],
          steps: [
            ServiceStep(
              title: 'Filing of Complaint',
              office: 'Business Permit and Licensing Office',
              instruction: 'Shall submit filled out Customer Complaint Form.',
            ),
          ],
        ),
      ], 
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 hr 30 minutes',
      personnel: 'Marvic Vasquez',
      cost: 'P 150.00',
    ),

    // Construction Permits Application
    'Construction Permits Application': ServiceDetail(
      title: 'Construction Permits Application',
      description: 'Application for Registration Program of Youth and Youth Serving Organizations.',
      tabs: [
        ServiceTab(
          name: 'Walk-in',
          requirements: [
            'Unified Application form for Building Permit, FSEC and Zoning/Locational Clearance',
            'NBC Forms (duly Accomplished Application Forms)',
            'Lot Plan (Signed & Sealed by Geodetic Engineer)',
            'Building Plans (Signed & Sealed by Professionals)',
            'Notarized Bill of Materials (Signed & sealed by professionals)',
            'Structural Analysis (if Applicable)',
            'Technical Specifications',
            'Soil Investigation / Test (if applicable)',
            'Approved Construction Safety and Health Program from Department of Labor and Employment (DOLE)',
            'Transfer Certificate of Title',
            'Contract of Lease or Deed of Absolute Sale (if TCT is not available)',
            'Tax Declaration',
            'Tax Receipt',
            'Barangay Clearance for Construction with no objection',
            'Homeowners’ Clearance',
            'Tax Identification Number',
            'Community Tax Certificate',
            'Construction Logbook(signed and sealed by Architect or Engineer in-charge of construction)',
          ],
          steps: [
            ServiceStep(
              title: 'Sumbit Requirements',
              office: 'Office of the Building Official',
              instruction: 'The applicant submits the filledup Unified Application Form for Building Permit, FSEC and Zoning/Locational Clearance together with the requirements.\n (Application forms and the list of requirements may be downloaded from the Office of the Building Official – Binan FB Page)',
            ),
            ServiceStep(
              title: 'Payment',
              office: 'Office of the Building Official',
              instruction: 'The applicant receives the Order of Payment and pays at the City Treasurer’s Office.',
            ),
            ServiceStep(
              title: 'Submit the Official Receipt',
              office: 'Office of the Building Official',
              instruction: 'The Applicant submits the Official Receipt then signs the logbook signifying the receipt of the Building Permits, Clearances and other documents.',
            ),
          ],
        ),
      ], 
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 hr 30 minutes',
      personnel: 'CPDO Staff',
      cost: 'Permit fees are based on the provisions stated in the NBCP',
    ),

    // Certificate of Final Electrical Inspection (CFEI) Application
    'Certificate of Final Electrical Inspection (CFEI) Application': ServiceDetail(
      title: 'Certificate of Final Electrical Inspection (CFEI) Application',
      description: 'Application for CFEI.',
      tabs: [
        ServiceTab(
          name: 'Walk-in',
          requirements: [
            'For Temporary Connection: Approved Building Permit',
            'For Temporary Connection: Approved Electrical Permit Contract of Form',
            'For Temporary Connection: Yellow Card issued by Service Provide',
            'Permanent Connection: Occupancy Permit',
            'Permanent Connection: Electrical Inspection Form signed by the owner/applicant',
            'Permanent Connection: Yellow Card issued by Service Provider',
          ],
          steps: [
            ServiceStep(
              title: 'Sumbit Requirements',
              office: 'Office of the Building Official',
              instruction: 'The applicant submits the requirements to assigned staff and waits for the schedule for inspection.',
            ),
            ServiceStep(
              title: 'Payment',
              office: 'Office of the Building Official',
              instruction: 'After inspection, the applicant submits the complete requirements, and the applicant receives the Order of Payment and proceeds to the City Treasurer’s Office for issuance of Official Receipt.',
            ),
            ServiceStep(
              title: 'Submit the Official Receipt',
              office: 'Office of the Building Official',
              instruction: 'The applicant shall submit the Official Receipt to the Office of the Building Official and receives the approved CFEI.',
            ),
          ],
        ),
      ], 
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 Day',
      personnel: 'OBO Staff',
      cost: 'Permit fees are based on the IRR of the NBCP',
    ),

    // Issuance of Certificate of Annual Inspection
    'Issuance of Certificate of Annual Inspection': ServiceDetail(
      title: 'Issuance of Certificate of Annual Inspection',
      description: 'Application for Certificate of Annual Inspection.',
      tabs: [
        ServiceTab(
          name: 'Renewal of Business Permit Application',
          requirements: [
            'Duly accomplished business permit application form',
          ],
          steps: [
            ServiceStep(
              title: 'Sumbit Requirements',
              office: 'Office of the Building Official',
              instruction: 'The applicant submits the duly accomplished application form.',
            ),
            ServiceStep(
              title: 'Payment',
              office: 'Office of the Building Official',
              instruction: 'The applicant receives the Order of Payment and proceeds to the City Treasurer’s Office for issuance of Official Receipt.',
            ),
            ServiceStep(
              title: 'Submit the Official Receipt',
              office: 'Office of the Building Official',
              instruction: 'The applicant shall submit the Official Receipt to the Office of the Building Official and receives the approved business permit.',
            ),
          ],
        ),


        ServiceTab(
          name: 'New Business Permit Application',
          requirements: [
            'Duly accomplished business permit application form',
            'Certificate of Occupancy',
            'Sketch of Location',
          ],
          steps: [
            ServiceStep(
              title: 'Sumbit Requirements',
              office: 'Office of the Building Official',
              instruction: 'The applicant submits the duly accomplished application form.',
            ),
            ServiceStep(
              title: 'Payment',
              office: 'Office of the Building Official',
              instruction: 'The applicant receives the Order of Payment and proceeds to the City Treasurer’s Office for issuance of Official Receipt.',
            ),
            ServiceStep(
              title: 'Submit the Official Receipt',
              office: 'Office of the Building Official',
              instruction: 'The applicant shall submit the Official Receipt to the Office of the Building Official and receives the approved business permit.',
            ),
          ],
        ),
      ], 
      location: 'Ground Floor, Biñan City Hall',
      duration: '2 hrs',
      personnel: 'OBO Staff',
      cost: 'Permit fees are based on the IRR of the NBCP',
    ),

     // Certificate of Occupancy Application
    'Certificate of Occupancy Application': ServiceDetail(
      title: 'Certificate of Occupancy Application',
      description: 'Application for Certificate of Occupancy',
      tabs: [
        ServiceTab(
          name: 'Walk-in',
          requirements: [
            'Certificate of Completion Form',
            'Approved Building permit',
            'Approved Electrical Permit',
            'Approved Plumbing Permit',
            'Approved Mechanical Permit',
            'Filled-up Unified Application form for Certificate of Occupancy',
            'Fire Safet Inspection Certificate (FSIC)',
            'Three (3) copies of duly notarizes Certificate of Completion, signed by the owner and signed and sealed by duly licensed Architect or Engineer -in-charge of construction',
            'Copy of Valid Licenses of all Professionals involved (e.g. Tax Receipt and the Professional Regulation Commission identification card)',
            'Captured Photograph of the completed structure showing front, sides and rear areas',
            'If changes were made – As built Plans',
          ],
          steps: [
            ServiceStep(
              title: 'Sumbit Requirements',
              office: 'Office of the Building Official',
              instruction: 'The applicant submits the requirements and accomplished form to assigned staff and waits for the schedule of inspection.',
            ),
            ServiceStep(
              title: 'Payment',
              office: 'Office of the Building Official',
              instruction: 'If documents are complete, the applicant is issued the Order of payment and proceeds to the City Treasurer’s Office for Official Receipt.',
            ),
            ServiceStep(
              title: 'Submit the Official Receipt',
              office: 'Office of the Building Official',
              instruction: 'The applicant shall submit the Official Receipt to the Office of the Building Official and receives the approved Certificate of Occupancy.',
            ),
          ],
        ),
      ], 
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 hr 30 minutes',
      personnel: 'OBO Staff',
      cost: 'Permit fees are based on the provisions stated in the NBCP',
    ),

    // Project Preparation
    'Project Preparation': ServiceDetail(
      title: 'Project Preparation',
      description: 'Preparation of Program of Works and Detailed Plans',
      tabs: [
        ServiceTab(
          name: 'Walk-in',
          requirements: [
            'Request letter with approval of the City Mayor',
          ],
          steps: [
            ServiceStep(
              title: 'Sumbit Request Letter',
              office: 'Office of the City Engineer',
              instruction: 'Submit the request letter to the Office of the Mayor.',
            ),
          ],
        ),
      ], 
      location: 'Ground Floor, Biñan City Hall',
      duration: '10 Days',
      personnel: 'Engineering Staff',
      cost: 'None',
    ),

    // Project Preparation
    'Project Implementation': ServiceDetail(
      title: 'Project Implementation',
      description: 'Implementation, monitoring andprocessing of payment for infrastructure projects (construction, maintenance, improvement and repair of roads, bridges and other engineering and public works projects of the City)',
      tabs: [
        ServiceTab(
          name: 'Walk-in',
          requirements: [
            'For project implementation - Approved Program of Works and detailed plan, copy of bid proposal from winning bidder, Notice of Award from the BAC, Contract and Notice to proceed',
            'For progress billing or full payment – List of Requirements for Partial/Full Payment',
          ],
          steps: [
            ServiceStep(
              title: 'Request',
              office: 'Office of the City Engineer',
              instruction: 'Request for site inspection with Engineering staff',
            ),

            ServiceStep(
              title: 'Payment',
              office: 'Office of the City Engineer',
              instruction: 'Request for partial/full Payment',
            ),

            ServiceStep(
              title: 'Submit Requirements',
              office: 'Office of the City Engineer',
              instruction: 'After submission of complete requirements',
            ),
          ],
        ),
      ], 
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 Day',
      personnel: 'Engineering Staff',
      cost: 'None',
    ),

    // Repair and Maintenance of Streetlights
    'Repair and Maintenance of Streetlights': ServiceDetail(
      title: 'Repair and Maintenance of Streetlights',
      description: 'Repair and maintenance of streetlights in the various barangays',
      tabs: [
        ServiceTab(
          name: 'Walk-in',
          requirements: [
            'Request letter from barangay ',
          ],
          steps: [
            ServiceStep(
              title: 'Request',
              office: 'Office of the City Engineer',
              instruction: 'Submit request letter to the Barangay Captain',
            ),
          ],
        ),
      ], 
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 Day',
      personnel: 'Engineering Staff',
      cost: 'None',
    ),

    // Project Preparation and Implementation for Barangays
    'Project Preparation and Implementation for Barangays': ServiceDetail(
      title: 'Project Preparation and Implementation for Barangays',
      description: 'Preparation of Program of Works and Detailed Plans, implementation and monitoring',
      tabs: [
        ServiceTab(
          name: 'Walk-in',
          requirements: [
            'Request letter with approval of the City Mayor',
          ],
          steps: [
            ServiceStep(
              title: 'Submit the Request Letter',
              office: 'Office of the City Engineer',
              instruction: 'Submit the request letter to the Office of the Mayor for approval',
            ),

            ServiceStep(
              title: 'Request',
              office: 'Office of the City Engineer',
              instruction: 'Request for project implementation and monitoring',
            ),

            ServiceStep(
              title: 'Payment',
              office: 'Office of the City Engineer',
              instruction: 'Request for payment',
            ),
          ],
        ),
      ], 
      location: 'Ground Floor, Biñan City Hall',
      duration: '1 Day',
      personnel: 'Engineering Staff',
      cost: 'None',
    ),

  };
  static ServiceDetail getDetail(String title) {
    return _allServices[title] ?? _allServices.values.first;
  }
}