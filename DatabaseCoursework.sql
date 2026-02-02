CREATE TABLE Branch (
    branch_id SERIAL PRIMARY KEY, 
    branch_name VARCHAR(100) UNIQUE NOT NULL,
    branch_location VARCHAR(100),
    capacity INT NOT NULL CHECK (capacity > 0)
);

CREATE TABLE Skill (
    skill_id SERIAL PRIMARY KEY,
    skill_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Part (
    part_id SERIAL PRIMARY KEY,
    part_name VARCHAR(100) UNIQUE NOT NULL,
    unit_cost DECIMAL(10, 2) NOT NULL CHECK (unit_cost > 0),
    part_category VARCHAR(100) NOT NULL  
);

CREATE TABLE Service (
    service_id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) UNIQUE NOT NULL,
    service_desc VARCHAR(500),
    duration INTERVAL NOT NULL, 
    service_cost DECIMAL(10, 2) NOT NULL CHECK (service_cost > 0)
);

CREATE TABLE ServicePackage (
    package_id SERIAL PRIMARY KEY,
    package_name VARCHAR(100) UNIQUE NOT NULL,
    package_total_cost DECIMAL(10, 2) NOT NULL CHECK (package_total_cost > 0)
);

CREATE TABLE Membership (
    membership_id SERIAL PRIMARY KEY,
    tier_name VARCHAR(50) NOT NULL CHECK (tier_name IN ('Gold', 'Silver', 'Bronze')),
    discount_percentage INT NOT NULL CHECK (discount_percentage BETWEEN 0 AND 100),
    annual_cost DECIMAL(10, 2)NOT NULL CHECK (annual_cost > 0),
    monthly_cost DECIMAL(10, 2) NOT NULL CHECK (monthly_cost > 0),
    fast_booking BOOLEAN DEFAULT FALSE NOT NULL,

    CONSTRAINT unique_tier UNIQUE (tier_name)
);

CREATE TABLE Staff (
    staff_id SERIAL PRIMARY KEY,
    branch_id INT NOT NULL REFERENCES Branch(branch_id),
    staff_fname VARCHAR(100) NOT NULL,
    staff_lname VARCHAR(100) NOT NULL,
    staff_email VARCHAR(100) UNIQUE NOT NULL,
    staff_phone VARCHAR(15) UNIQUE NOT NULL,
    hire_date DATE NOT NULL
);

CREATE TABLE Bay (
    bay_id SERIAL PRIMARY KEY,
    branch_id INT NOT NULL REFERENCES Branch(branch_id),
    last_inspected DATE,
    bay_status VARCHAR(50) NOT NULL DEFAULT 'Available' CHECK (bay_status IN ('Available', 'Occupied', 'Maintenance'))
);

CREATE TABLE PackageServiceLink (
    package_id INT NOT NULL REFERENCES ServicePackage(package_id),
    service_id INT NOT NULL REFERENCES Service(service_id),
    PRIMARY KEY (package_id, service_id)
);

CREATE TABLE Customer (
    customer_id SERIAL PRIMARY KEY,
    membership_id INT REFERENCES Membership(membership_id),
    membership_billing_type VARCHAR(50) CHECK (membership_billing_type IN ('Monthly', 'Annual')),
    customer_fname VARCHAR(100) NOT NULL,
    customer_lname VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100) UNIQUE NOT NULL,
    customer_phone VARCHAR(15) UNIQUE NOT NULL,
    customer_address VARCHAR(255) NOT NULL,

    CHECK (
    (membership_id IS NULL AND membership_billing_type IS NULL) OR
    (membership_id IS NOT NULL AND membership_billing_type IS NOT NULL)
)
);

CREATE TABLE StaffSkill (
    staff_id INT NOT NULL REFERENCES Staff(staff_id),
    skill_id INT NOT NULL REFERENCES Skill(skill_id),
    PRIMARY KEY (staff_id, skill_id)
);

CREATE TABLE StaffRole (
    staff_id INT NOT NULL REFERENCES Staff(staff_id),
    role_id INT NOT NULL REFERENCES Role(role_id),
    PRIMARY KEY (staff_id, role_id)
);

CREATE TABLE Shift (
    shift_id SERIAL PRIMARY KEY, 
    staff_id INT NOT NULL REFERENCES Staff(staff_id),
    branch_id INT NOT NULL REFERENCES Branch(branch_id),
    shift_start TIME NOT NULL,
    shift_end TIME NOT NULL,
    shift_date DATE NOT NULL
);

CREATE TABLE Vehicle (
    vehicle_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES Customer(customer_id),
    car_year INT NOT NULL,
    car_model VARCHAR(100) NOT NULL,
    car_reg VARCHAR(50) UNIQUE NOT NULL,
    car_origin VARCHAR(50) NOT NULL,
    vin VARCHAR(20) UNIQUE NOT NULL,
    mot_date DATE 
);

CREATE TABLE EmergencyContact (
    contact_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES Customer(customer_id),
    contact_fname VARCHAR(100) NOT NULL,
    contact_lname VARCHAR(100) NOT NULL,
    contact_phone VARCHAR(15) NOT NULL UNIQUE,
    contact_address VARCHAR(255)
);

CREATE TABLE Booking (
    booking_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES Customer(customer_id),
    vehicle_id INT NOT NULL REFERENCES Vehicle(vehicle_id),
    branch_id INT NOT NULL REFERENCES Branch(branch_id),
    booking_date DATE NOT NULL,
    scheduled_time TIME NOT NULL,
    booking_status VARCHAR(50) NOT NULL DEFAULT 'Scheduled' CHECK (booking_status IN ('Scheduled', 'Completed', 'Cancelled'))
);

CREATE TABLE Task (
    task_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES Booking(booking_id),
    service_id INT NOT NULL REFERENCES Service(service_id),
    staff_id INT NOT NULL REFERENCES Staff(staff_id),
    task_status VARCHAR(50) NOT NULL DEFAULT 'Pending' CHECK (task_status IN ('Pending', 'In Progress', 'Completed')),
    time_taken DECIMAL (5, 2)
);

CREATE TABLE VehicleAllocation (
    allocation_id SERIAL PRIMARY KEY,
    vehicle_id INT NOT NULL REFERENCES Vehicle(vehicle_id),
    booking_id INT NOT NULL REFERENCES Booking(booking_id),
    bay_id INT NOT NULL REFERENCES Bay(bay_id),
    staff_id INT NOT NULL REFERENCES Staff(staff_id)
);

CREATE TABLE Invoice (
    invoice_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES Booking(booking_id),
    invoice_total DECIMAL(10, 2) NOT NULL CHECK (invoice_total > 0),
    invoice_status VARCHAR(50) NOT NULL DEFAULT 'Due' CHECK (invoice_status IN ('Due', 'Paid', 'Overdue', 'Partially Paid')),
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL
);

CREATE TABLE CommunicationLog (
    log_id SERIAL PRIMARY KEY,
    booking_id INT REFERENCES Booking(booking_id),
    customer_id INT NOT NULL REFERENCES Customer(customer_id),
    channel VARCHAR(50) NOT NULL CHECK (channel IN ('Email', 'Phone', 'SMS')),
    message_content VARCHAR(500) NOT NULL,
    date_sent DATE NOT NULL
);

CREATE TABLE Feedback (
    feedback_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES Booking(booking_id),
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    feedback_desc VARCHAR(500),
    feedback_date DATE NOT NULL,
    resolution_status VARCHAR(50) NOT NULL DEFAULT 'Open' CHECK (resolution_status IN ('Open', 'In Progress', 'Resolved')),
    resolution_desc VARCHAR(500),
    resolved_by_staff INT REFERENCES Staff(staff_id)
);

CREATE TABLE Usage (
    usage_id SERIAL PRIMARY KEY,
    task_id INT NOT NULL REFERENCES Task(task_id),
    part_id INT NOT NULL REFERENCES Part(part_id),
    quantity_used INT NOT NULL CHECK (quantity_used > 0)
);

CREATE TABLE Payment (
    payment_id SERIAL PRIMARY KEY,
    invoice_id INT NOT NULL REFERENCES Invoice(invoice_id),
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(10, 2) NOT NULL CHECK (payment_amount > 0),
    payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('Credit Card', 'Debit Card', 'Cash', 'Bank Transfer')),
    transaction_type VARCHAR(50) NOT NULL CHECK (transaction_type IN ('Full', 'Partial', 'Refund'))
);

CREATE TABLE ComplianceRecord (
    compliance_id SERIAL PRIMARY KEY,
    compliance_type VARCHAR(50) NOT NULL CHECK (compliance_type IN ('Certification', 'Bay Inspection', 'MOT', 'IVA', 'LOLER')),
    compliance_date DATE NOT NULL,
    compliance_result VARCHAR(50) NOT NULL CHECK (compliance_result IN ('Processing', 'Cancelled', 'Pass', 'Fail')),
    compliance_staff INT NOT NULL REFERENCES Staff(staff_id),
    compliance_bay INT REFERENCES Bay(bay_id),
    vehicle_id INT REFERENCES Vehicle(vehicle_id)
);

ALTER TABLE Branch
ADD COLUMN manager_staff_id INT REFERENCES Staff(staff_id);

CREATE TABLE BranchStock (
    branch_id INT NOT NULL REFERENCES Branch(branch_id),
    part_id INT NOT NULL REFERENCES Part(part_id),
    quantity_stock INT NOT NULL CHECK (quantity_stock >= 0),
    PRIMARY KEY (branch_id, part_id)
);

CREATE TABLE BookingItem (
    booking_item_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES Booking(booking_id),
    service_id INT REFERENCES Service(service_id),
    package_id INT REFERENCES ServicePackage(package_id),

    CONSTRAINT item_service_package_check CHECK (
        (service_id IS NOT NULL AND package_id IS NULL) OR
        (service_id IS NULL AND package_id IS NOT NULL)
    )
);

insert into Branch (branch_id, branch_name, branch_location, capacity) values (1, 'Mann-Littel', '8 Calypso Way', 9);
insert into Branch (branch_id, branch_name, branch_location, capacity) values (2, 'Anderson-Kassulke', '76 Meadow Valley Center', 6);
insert into Branch (branch_id, branch_name, branch_location, capacity) values (3, 'Schoen-Prosacco', '4071 Emmet Street', 6);
insert into Branch (branch_id, branch_name, branch_location, capacity) values (4, 'Crona Group', '42612 Marquette Way', 6);
insert into Branch (branch_id, branch_name, branch_location, capacity) values (5, 'West-Reynolds', '02 Lillian Way', 5);
insert into Branch (branch_id, branch_name, branch_location, capacity) values (6, 'O''Kon, Skiles and Oberbrunner', '20646 North Way', 15);
insert into Branch (branch_id, branch_name, branch_location, capacity) values (7, 'Howe, Krajcik and Farrell', '4153 Michigan Court', 13);
insert into Branch (branch_id, branch_name, branch_location, capacity) values (8, 'Nolan, Upton and Lemke', '0 Graceland Pass', 14);
insert into Branch (branch_id, branch_name, branch_location, capacity) values (9, 'Stracke-Zulauf', '63165 Canary Terrace', 10);
insert into Branch (branch_id, branch_name, branch_location, capacity) values (10, 'Murray, Fay and Shields', '2 Northport Point', 6);
insert into Branch (branch_id, branch_name, branch_location, capacity) values (11, 'Williamson', '0 Brickson Park Crossing', 14);
insert into Branch (branch_id, branch_name, branch_location, capacity) values (12, 'Anderson', '20 Briar Crest Park', 9);
insert into Branch (branch_id, branch_name, branch_location, capacity) values (13, 'Waters-Volkman', '3349 Talmadge Point', 11);
insert into Branch (branch_id, branch_name, branch_location, capacity) values (14, 'Kiehn, Keeling and Kunde', '202 Summer Ridge Court', 10);
insert into Branch (branch_id, branch_name, branch_location, capacity) values (15, 'Yundt, McKenzie and Conn', '75 Anhalt Way', 8);

insert into Skill (skill_id, skill_name) values (1, 'Switchgear');
insert into Skill (skill_id, skill_name) values (2, 'Hybrid Vehicles');
insert into Skill (skill_id, skill_name) values (3, 'Payroll');
insert into Skill (skill_id, skill_name) values (4, 'Workers Compensation');
insert into Skill (skill_id, skill_name) values (5, 'Welding');
insert into Skill (skill_id, skill_name) values (6, 'Bodywork');
insert into Skill (skill_id, skill_name) values (7, 'Diagnostics');
insert into Skill (skill_id, skill_name) values (8, 'Engine Repair');
insert into Skill (skill_id, skill_name) values (9, 'Coding');
insert into Skill (skill_id, skill_name) values (10, 'MOT Testing');

insert into Role (role_id, role_name) values (1, 'Technician');
insert into Role (role_id, role_name) values (2, 'Manager');
insert into Role (role_id, role_name) values (3, 'Apprentice');
insert into Role (role_id, role_name) values (4, 'Receptionist');

INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(1, 'Synthetic Engine Oil (5L)', 35.00, 'Consumable');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(2, 'Windscreen Washer Fluid (5L)', 6.50, 'Consumable');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(3, 'Antifreeze / Coolant (1L)', 8.00, 'Consumable');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(4, 'Brake Fluid DOT4', 12.00, 'Consumable');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(5, 'Power Steering Fluid', 15.50, 'Consumable');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(6, 'Transmission Fluid', 18.00, 'Consumable');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(7, 'Air Filter', 14.50, 'Consumable');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(8, 'Cabin Filter', 12.00, 'Consumable');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(9, 'Wiper Blade (Front Left)', 16.00, 'Consumable');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(10, 'Wiper Blade (Front Right)', 16.00, 'Consumable');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(11, 'Wiper Blade (Rear)', 10.00, 'Consumable');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(12, 'Front Brake Disc (Vented)', 45.00, 'Braking');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(13, 'Rear Brake Disc (Solid)', 30.00, 'Braking');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(14, 'Front Brake Pad Set', 35.00, 'Braking');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(15, 'Rear Brake Pad Set', 28.00, 'Braking');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(16, 'Brake Caliper (Front Left)', 85.00, 'Braking');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(17, 'Brake Caliper (Front Right)', 85.00, 'Braking');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(18, 'ABS Sensor', 22.50, 'Braking');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(19, 'Timing Belt Kit', 120.00, 'Engine');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(20, 'Water Pump', 45.00, 'Engine');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(21, 'Alternator Belt', 18.00, 'Engine');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(22, 'Spark Plug (Single)', 8.50, 'Engine');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(23, 'Glow Plug (Single)', 12.50, 'Engine');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(24, 'Clutch Kit', 150.00, 'Transmission');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(25, 'Flywheel (Dual Mass)', 250.00, 'Transmission');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(26, 'Starter Motor', 110.00, 'Engine');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(27, 'Alternator', 140.00, 'Engine');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(28, 'Fuel Filter', 20.00, 'Engine');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(29, 'Fuel Pump', 95.00, 'Engine');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(30, 'Radiator', 85.00, 'Engine');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(31, 'Thermostat', 15.00, 'Engine');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(32, 'Shock Absorber (Front)', 60.00, 'Suspension');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(33, 'Shock Absorber (Rear)', 50.00, 'Suspension');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(34, 'Coil Spring (Front)', 35.00, 'Suspension');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(35, 'Lower Control Arm', 75.00, 'Suspension');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(36, 'Wheel Bearing Kit', 40.00, 'Suspension');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(37, 'Track Rod End', 25.00, 'Steering');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(38, 'Steering Rack', 200.00, 'Steering');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(39, 'Headlight Bulb (H7)', 6.00, 'Electrical');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(40, 'Tail Light Bulb', 2.50, 'Electrical');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(41, 'Indicator Bulb (Amber)', 2.00, 'Electrical');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(42, 'Car Battery (60Ah)', 80.00, 'Electrical');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(43, 'Car Battery (70Ah)', 95.00, 'Electrical');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(44, 'Fuse Set (Mixed)', 5.00, 'Electrical');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(45, 'Lambda Sensor', 65.00, 'Electrical');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(46, 'Exhaust Silencer (Rear)', 70.00, 'Exhaust');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(47, 'Exhaust Manifold', 120.00, 'Exhaust');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(48, 'Catalytic Converter', 300.00, 'Exhaust');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(49, 'Wing Mirror Glass', 15.00, 'Body');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(50, 'Wing Mirror Unit (Electric)', 110.00, 'Body');
INSERT INTO Part (part_id, part_name, unit_cost, part_category) VALUES(51, 'Number Plate Light', 8.00, 'Body');


insert into Service (service_id, service_name, service_desc, duration, service_cost) values (1, 'Speedy Auto Care', 'Toxic effect of other pesticides, undetermined, subs encntr', '30 minutes', 50);
insert into Service (service_id, service_name, service_desc, duration, service_cost) values (2, 'Elite Car Detailing', 'Displ commnt fx shaft of r tibia, 7thC', '1 hour', 75);
insert into Service (service_id, service_name, service_desc, duration, service_cost) values (3, 'Revved Up Repairs', 'Nondisp Maisonneuve''s fx unsp leg, 7thM', '45 minutes', 100);
insert into Service (service_id, service_name, service_desc, duration, service_cost) values (4, 'Luxury Auto Spa', 'Maternal care for oth rhesus isoimmun, third trimester, oth', '2 hours', 125);
insert into Service (service_id, service_name, service_desc, duration, service_cost) values (5, 'Quick Fix Garage', 'Athscl nonaut bio bypass of the left leg w ulcer of thigh', '20 minutes', 150);
insert into Service (service_id, service_name, service_desc, duration, service_cost) values (6, 'Smooth Ride Services', 'Contact with dry ice, initial encounter', '1.5 hours', 175);
insert into Service (service_id, service_name, service_desc, duration, service_cost) values (7, 'Top Gear Tune-Up', 'Listeriosis', '40 minutes', 200);
insert into Service (service_id, service_name, service_desc, duration, service_cost) values (8, 'Sparkling Clean Car Wash', 'Xeroderma of right lower eyelid', '3 hours', 225);
insert into Service (service_id, service_name, service_desc, duration, service_cost) values (9, 'Fast Lane Mechanics', 'Inj l int crtd, intcr w LOC of 30 minutes or less, sequela', '25 minutes', 250);
insert into Service (service_id, service_name, service_desc, duration, service_cost) values (10, 'Precision Auto Body', 'Diagnostic agents', '1.25 hours', 275);

insert into ServicePackage (package_id, package_name, package_total_cost) values (1, 'Gold Detailing Package', 500);
insert into ServicePackage (package_id, package_name, package_total_cost) values (2, 'Platinum Interior Cleaning', 750);
insert into ServicePackage (package_id, package_name, package_total_cost) values (3, 'Ultimate Paint Protection', 1000);
insert into ServicePackage (package_id, package_name, package_total_cost) values (4, 'Deluxe Tire Shine', 1200);

insert into membership (membership_id, tier_name, discount_percentage, annual_cost, monthly_cost, fast_booking) values (1, 'Gold', 50, 500, 50, true);
insert into membership (membership_id, tier_name, discount_percentage, annual_cost, monthly_cost, fast_booking) values (2, 'Silver', 20, 300, 30, false);
insert into membership (membership_id, tier_name, discount_percentage, annual_cost, monthly_cost, fast_booking) values (3, 'Bronze', 10, 150, 15, false);

insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (1, 1, 'Nomi', 'Christopher', 'nchristopher0@yale.edu', '858-317-2466', '10/31/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (2, 2, 'Vladimir', 'Sorokin', 'tstopper1@mysql.com', '668-254-7372', '6/20/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (3, 3, 'Rosina', 'O''Bradain', 'robradain2@addthis.com', '931-955-8355', '6/6/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (4, 4, 'Denni', 'Oakey', 'doakey3@quantcast.com', '831-182-7444', '10/20/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (5, 5, 'Eddie', 'McNirlin', 'emcnirlin4@state.gov', '976-841-2347', '8/11/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (6, 6, 'Sunshine', 'Pakes', 'spakes5@sakura.ne.jp', '745-184-3687', '8/27/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (7, 7, 'Reiko', 'Kikke', 'rkikke6@sfgate.com', '145-781-9729', '3/29/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (8, 8, 'Christiane', 'Fowle', 'cfowle7@si.edu', '536-709-7444', '5/5/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (9, 9, 'Jacklin', 'Orknay', 'jorknay8@hhs.gov', '280-418-9322', '10/6/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (10, 10, 'Jacinthe', 'Tithecott', 'jtithecott9@amazonaws.com', '158-113-2618', '5/8/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (11, 11, 'Samaria', 'Tiller', 'stillera@sitemeter.com', '555-434-4046', '12/14/2024');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (12, 12, 'Bil', 'Toynbee', 'btoynbeeb@slideshare.net', '802-962-1093', '3/31/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (13, 13, 'Thomasine', 'Bray', 'tbrayc@msn.com', '985-640-4646', '3/2/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (14, 14, 'Darcy', 'Folbig', 'dfolbigd@state.tx.us', '857-328-8442', '3/5/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (15, 15, 'Jayme', 'Gage', 'jgagee@goo.gl', '803-295-8216', '7/22/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (16, 1, 'Elyssa', 'Oddey', 'eoddeyf@accuweather.com', '538-864-9340', '2/21/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (17, 2, 'Kelsey', 'Line', 'klineg@microsoft.com', '970-720-9293', '5/8/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (18, 3, 'Rica', 'Panons', 'rpanonsh@google.es', '128-838-6578', '10/23/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (19, 4, 'Kandy', 'Dickin', 'kdickini@gnu.org', '432-733-2032', '12/2/2024');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (20, 5, 'Lonnie', 'Dunbobbin', 'ldunbobbinj@google.nl', '489-932-5732', '6/21/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (21, 6, 'Petronille', 'Mayne', 'pmaynek@sun.com', '128-176-7841', '9/11/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (22, 7, 'Sylvia', 'Leppingwell', 'sleppingwelll@google.com', '623-561-1084', '5/25/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (23, 8, 'Kirill', 'Granich', 'agiblinm@squarespace.com', '859-168-6321', '7/26/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (24, 9, 'Melita', 'Casier', 'mcasiern@paginegialle.it', '732-519-2924', '6/20/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (25, 10, 'Nicholas', 'Bryning', 'nbryningo@fda.gov', '421-830-8339', '7/17/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (26, 11, 'Elenore', 'Fazzioli', 'efazziolip@umn.edu', '236-339-5149', '9/2/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (27, 12, 'Andros', 'Deniske', 'adeniskeq@about.me', '457-951-8898', '12/17/2024');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (28, 13, 'Gates', 'Oaks', 'goaksr@virginia.edu', '821-578-4178', '9/14/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (29, 14, 'Gavan', 'Nare', 'gnares@gravatar.com', '243-134-3779', '9/16/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (30, 15, 'Timmy', 'Hantusch', 'thantuscht@msu.edu', '573-601-3899', '3/26/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (31, 1, 'Suzi', 'Ashard', 'sashard0@miibeian.gov.cn', '335-403-4171', '2/13/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (32, 2, 'Archambault', 'Leachman', 'aleachman1@reuters.com', '213-758-0639', '7/23/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (33, 3, 'Maribel', 'Gemelli', 'mgemelli2@gnu.org', '717-264-6438', '11/1/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (34, 4, 'Hermia', 'Thurston', 'hthurston3@thetimes.co.uk', '547-656-4257', '9/29/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (35, 5, 'Saree', 'Brittain', 'sbrittain4@dropbox.com', '335-710-6511', '10/21/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (36, 6, 'Mathias', 'Tidmarsh', 'mtidmarsh5@webnode.com', '689-300-6508', '6/23/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (37, 9, 'Lorrie', 'Pagnin', 'lpagnin6@slate.com', '301-231-4936', '1/24/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (38, 10, 'Dasya', 'Briereton', 'dbriereton7@wordpress.com', '715-737-7359', '1/8/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (39, 11, 'Codie', 'Kenneford', 'ckenneford8@lycos.com', '807-508-2276', '3/13/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (40, 13, 'Hubey', 'Spiaggia', 'hspiaggia9@buzzfeed.com', '966-370-1440', '5/11/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (41, 14, 'Cari', 'Joselson', 'cjoselsona@newsvine.com', '924-136-0392', '3/14/2025');
insert into staff (staff_id, branch_id, staff_fname, staff_lname, staff_email, staff_phone, hire_date) values (42, 15, 'Ignacius', 'McEllen', 'imcellenb@4shared.com', '191-662-1691', '8/28/2025');

insert into bay (bay_id, branch_id, last_inspected, bay_status) values (1, 10, '6/15/2025', 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (2, 9, '7/22/2025', 'Available');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (3, 6, null, 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (4, 8, null, 'Occupied');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (5, 6, '10/30/2025', 'Occupied');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (6, 5, null, 'Available');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (7, 1, null, 'Available');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (8, 3, null, 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (9, 8, null, 'Occupied');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (10, 7, '4/6/2025', 'Available');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (11, 7, '12/18/2024', 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (12, 9, '9/8/2025', 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (13, 8, '5/9/2025', 'Available');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (14, 7, '11/6/2025', 'Available');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (15, 14, '7/27/2025', 'Available');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (16, 13, '11/14/2025', 'Available');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (17, 8, null, 'Available');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (18, 3, '5/30/2025', 'Occupied');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (19, 9, '7/21/2025', 'Available');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (20, 2, '8/6/2025', 'Occupied');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (21, 11, '8/9/2025', 'Occupied');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (22, 5, '4/29/2025', 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (23, 7, '9/2/2025', 'Occupied');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (24, 9, '10/23/2025', 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (25, 14, '4/3/2025', 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (26, 2, '11/6/2025', 'Available');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (27, 6, '1/20/2025', 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (28, 15, '7/17/2025', 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (29, 8, null, 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (30, 10, '11/8/2025', 'Available');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (31, 10, '2/13/2025', 'Occupied');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (32, 4, '10/21/2025', 'Available');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (33, 8, '8/11/2025', 'Available');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (34, 15, '6/30/2025', 'Occupied');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (35, 13, '5/18/2025', 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (36, 9, '3/30/2025', 'Occupied');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (37, 8, '12/14/2024', 'Available');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (38, 6, '8/19/2025', 'Available');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (39, 3, '6/7/2025', 'Occupied');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (40, 2, '6/29/2025', 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (41, 8, '4/29/2025', 'Occupied');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (42, 3, '6/30/2025', 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (43, 11, '2/22/2025', 'Available');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (44, 13, null, 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (45, 13, '2/4/2025', 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (46, 13, '5/20/2025', 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (47, 13, '4/23/2025', 'Maintenance');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (48, 6, '11/18/2025', 'Occupied');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (49, 2, '4/7/2025', 'Occupied');
insert into bay (bay_id, branch_id, last_inspected, bay_status) values (50, 9, '6/20/2025', 'Available');

insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (1, 3, 'Monthly', 'Lucia', 'Westman', 'lwestman0@scientificamerican.com', '115-922-2637', 'Room 718');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (2, 2, 'Monthly', 'Horacio', 'Reeds', 'hreeds1@msn.com', '417-844-5218', 'Room 357');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (3, 1, 'Monthly', 'Shaylyn', 'Crichley', 'scrichley2@go.com', '306-554-4674', 'Suite 69');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (4, null, null, 'Reamonn', 'Moy', 'rmoy3@joomla.org', '984-852-0085', 'Apt 979');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (5, null, null, 'Roxy', 'Lecky', 'rlecky4@studiopress.com', '597-228-5140', 'Apt 1537');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (6, null, null, 'Astrix', 'Huzzey', 'ahuzzey5@free.fr', '484-801-5084', 'Room 1501');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (7, null, null, 'Brittney', 'Purdy', 'bpurdy6@blogtalkradio.com', '136-959-5889', 'Suite 100');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (8, null, null, 'Olivie', 'Jenman', 'ojenman7@printfriendly.com', '190-483-1305', 'Apt 834');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (9, null, null, 'Noemi', 'Mathers', 'nmathers8@biblegateway.com', '938-936-5625', '4th Floor');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (10, 1, 'Monthly', 'Bobbee', 'Allright', 'ballright9@imageshack.us', '310-576-7481', 'Apt 1257');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (11, null, null, 'Wandis', 'Barbier', 'wbarbiera@weibo.com', '330-554-1832', '18th Floor');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (12, null, null, 'Cynde', 'Stuer', 'cstuerb@mapquest.com', '600-608-9782', 'Apt 1334');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (13, null, null, 'Roderich', 'Gashion', 'rgashionc@simplemachines.org', '442-495-8074', '1st Floor');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (14, null, null, 'Bay', 'Barcroft', 'bbarcroftd@aboutads.info', '285-643-5801', 'Room 1141');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (15, null, null, 'Valerie', 'Lanigan', 'vlanigane@shinystat.com', '668-534-3016', 'Suite 56');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (16, null, null, 'Retha', 'Kirman', 'rkirmanf@businesswire.com', '770-163-4396', 'Room 449');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (17, 1, 'Annual', 'Johnath', 'Monni', 'jmonnig@opera.com', '506-778-7511', 'PO Box 9205');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (18, null, null, 'Eziechiele', 'Spry', 'espryh@creativecommons.org', '236-690-0439', 'Apt 1378');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (19, null, null, 'Judie', 'Gudgen', 'jgudgeni@howstuffworks.com', '261-655-9289', 'Apt 1294');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (20, 1, 'Annual', 'Peggi', 'Marages', 'pmaragesj@woothemes.com', '755-801-8280', '1st Floor');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (21, null, null, 'Jone', 'Gerrit', 'jgerritk@wix.com', '988-820-5464', 'Suite 23');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (22, null, null, 'Isadore', 'Duthy', 'iduthyl@google.com', '738-555-0369', 'Room 13');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (23, null, null, 'Cheston', 'Yesenev', 'cyesenevm@guardian.co.uk', '895-601-3928', '18th Floor');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (24, 2, 'Monthly', 'Tirrell', 'Jobbins', 'tjobbinsn@netscape.com', '189-617-3358', 'Suite 7');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (25, null, null, 'Krishnah', 'Gomm', 'kgommo@gnu.org', '213-502-6698', '15th Floor');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (26, null, null, 'Sarette', 'Froom', 'sfroomp@freewebs.com', '199-731-0793', '19th Floor');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (27, null, null, 'Flori', 'Blainey', 'fblaineyq@businesswire.com', '716-209-3685', 'Suite 33');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (28, null, null, 'Becky', 'Robson', 'brobsonr@tiny.cc', '737-486-9855', 'Room 748');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (29, 2, 'Annual', 'Cordy', 'Wickens', 'cwickenss@businessweek.com', '691-456-6917', 'PO Box 90108');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (30, null, null, 'Glyn', 'Matiewe', 'gmatiewet@bbb.org', '148-527-0556', 'PO Box 88316');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (31, null, null, 'Bobby', 'Eton', 'betonu@multiply.com', '861-674-9279', '2nd Floor');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (32, null, null, 'Cleve', 'Baron', 'cbaronv@whitehouse.gov', '988-556-9876', 'PO Box 40234');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (33, null, null, 'Krissie', 'Philippe', 'kphilippew@bluehost.com', '995-912-1848', '7th Floor');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (34, 2, 'Annual', 'Reube', 'Spat', 'rspatx@technorati.com', '995-471-6694', 'Apt 299');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (35, 1, 'Monthly', 'Kikelia', 'Chene', 'kcheney@clickbank.net', '516-871-6407', 'Suite 45');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (36, 1, 'Annual', 'Amie', 'Moncreiffe', 'amoncreiffez@nps.gov', '525-782-7574', '3rd Floor');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (37, 1, 'Monthly', 'Christiano', 'Ormonde', 'cormonde10@unc.edu', '449-279-8386', '8th Floor');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (38, 1, 'Annual', 'Helenelizabeth', 'Degoe', 'hdegoe11@ed.gov', '867-351-4101', 'Room 1327');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (39, 2, 'Annual', 'Jonathan', 'Yeandel', 'jyeandel12@smugmug.com', '516-945-6319', 'Suite 99');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (40, null, null, 'Oralia', 'Brandes', 'obrandes13@godaddy.com', '575-279-3238', 'Apt 1122');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (41, 2, 'Annual', 'Bianca', 'Postan', 'bpostan14@jigsy.com', '349-462-9481', '7th Floor');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (42, 1, 'Annual', 'Haywood', 'Tyre', 'htyre15@weather.com', '585-268-7859', '19th Floor');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (43, 1, 'Monthly', 'Robyn', 'Eggers', 'reggers16@github.com', '562-460-5543', 'PO Box 96001');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (44, null, null, 'Philip', 'MacLennan', 'pmaclennan17@list-manage.com', '351-415-8189', 'Room 1581');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (45, 3, 'Monthly', 'Coleman', 'Nano', 'cnano18@ed.gov', '380-225-2914', 'Room 1253');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (46, 3, 'Annual', 'Tersina', 'Proffer', 'tproffer19@icq.com', '330-463-3690', 'Suite 55');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (47, 2, 'Annual', 'Blair', 'Haughin', 'bhaughin1a@seattletimes.com', '361-867-0478', 'Apt 1092');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (48, null, null, 'Randene', 'Bach', 'rbach1b@blinklist.com', '955-178-3102', 'Room 1822');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (49, null, null, 'Nert', 'Sinderland', 'nsinderland1c@marriott.com', '170-865-5429', 'Room 1712');
insert into customer (customer_id, membership_id, membership_billing_type, customer_fname, customer_lname, customer_email, customer_phone, customer_address) values (50, null, null, 'Pascal', 'Robertsen', 'probertsen1d@parallels.com', '573-622-1224', 'Suite 12');

insert into staffskill (staff_id, skill_id) values (1, 10);
insert into staffskill (staff_id, skill_id) values (2, 5);
insert into staffskill (staff_id, skill_id) values (3, 10);
insert into staffskill (staff_id, skill_id) values (4, 8);
insert into staffskill (staff_id, skill_id) values (5, 8);
insert into staffskill (staff_id, skill_id) values (6, 8);
insert into staffskill (staff_id, skill_id) values (7, 6);
insert into staffskill (staff_id, skill_id) values (8, 1);
insert into staffskill (staff_id, skill_id) values (9, 5);
insert into staffskill (staff_id, skill_id) values (10, 2);
insert into staffskill (staff_id, skill_id) values (11, 5);
insert into staffskill (staff_id, skill_id) values (12, 3);
insert into staffskill (staff_id, skill_id) values (13, 8);
insert into staffskill (staff_id, skill_id) values (14, 6);
insert into staffskill (staff_id, skill_id) values (15, 10);
insert into staffskill (staff_id, skill_id) values (16, 9);
insert into staffskill (staff_id, skill_id) values (17, 2);
insert into staffskill (staff_id, skill_id) values (18, 2);
insert into staffskill (staff_id, skill_id) values (19, 7);
insert into staffskill (staff_id, skill_id) values (20, 8);
insert into staffskill (staff_id, skill_id) values (21, 1);
insert into staffskill (staff_id, skill_id) values (22, 5);
insert into staffskill (staff_id, skill_id) values (23, 7);
insert into staffskill (staff_id, skill_id) values (24, 7);
insert into staffskill (staff_id, skill_id) values (25, 2);
insert into staffskill (staff_id, skill_id) values (26, 7);
insert into staffskill (staff_id, skill_id) values (27, 4);
insert into staffskill (staff_id, skill_id) values (28, 7);
insert into staffskill (staff_id, skill_id) values (29, 10);
insert into staffskill (staff_id, skill_id) values (30, 7);

insert into staffrole (staff_id, role_id) values (1, 2);
insert into staffrole (staff_id, role_id) values (2, 3);
insert into staffrole (staff_id, role_id) values (3, 4);
insert into staffrole (staff_id, role_id) values (4, 4);
insert into staffrole (staff_id, role_id) values (5, 1);
insert into staffrole (staff_id, role_id) values (6, 4);
insert into staffrole (staff_id, role_id) values (7, 3);
insert into staffrole (staff_id, role_id) values (8, 1);
insert into staffrole (staff_id, role_id) values (9, 1);
insert into staffrole (staff_id, role_id) values (10, 3);
insert into staffrole (staff_id, role_id) values (11, 4);
insert into staffrole (staff_id, role_id) values (12, 3);
insert into staffrole (staff_id, role_id) values (13, 1);
insert into staffrole (staff_id, role_id) values (14, 1);
insert into staffrole (staff_id, role_id) values (15, 4);
insert into staffrole (staff_id, role_id) values (16, 4);
insert into staffrole (staff_id, role_id) values (17, 4);
insert into staffrole (staff_id, role_id) values (18, 4);
insert into staffrole (staff_id, role_id) values (19, 1);
insert into staffrole (staff_id, role_id) values (20, 4);
insert into staffrole (staff_id, role_id) values (21, 1);
insert into staffrole (staff_id, role_id) values (22, 2);
insert into staffrole (staff_id, role_id) values (23, 2);
insert into staffrole (staff_id, role_id) values (24, 3);
insert into staffrole (staff_id, role_id) values (25, 3);
insert into staffrole (staff_id, role_id) values (26, 3);
insert into staffrole (staff_id, role_id) values (27, 2);
insert into staffrole (staff_id, role_id) values (28, 1);
insert into staffrole (staff_id, role_id) values (29, 3);
insert into staffrole (staff_id, role_id) values (30, 3);

insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (1, 1, 1, '12:18 AM', '4:57 PM', '4/10/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (2, 2, 2, '7:58 AM', '3:16 PM', '10/27/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (3, 3, 3, '4:18 AM', '5:45 PM', '6/26/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (4, 4, 4, '8:48 AM', '5:35 PM', '11/2/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (5, 5, 5, '1:28 AM', '3:55 PM', '8/20/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (6, 6, 6, '4:16 AM', '3:47 PM', '2/17/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (7, 7, 7, '1:40 AM', '5:33 PM', '4/3/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (8, 8, 8, '2:03 AM', '3:17 PM', '5/21/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (9, 9, 9, '5:26 AM', '4:53 PM', '1/18/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (10, 10, 10, '6:11 AM', '3:23 PM', '4/3/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (11, 11, 11, '4:38 AM', '4:48 PM', '4/15/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (12, 12, 12, '4:06 AM', '4:24 PM', '9/14/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (13, 13, 13, '5:42 AM', '4:39 PM', '8/7/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (14, 14, 14, '6:18 AM', '3:50 PM', '9/17/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (15, 15, 15, '7:52 AM', '3:06 PM', '5/31/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (16, 16, 1, '7:35 AM', '4:43 PM', '5/5/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (17, 17, 2, '3:31 AM', '4:36 PM', '2/6/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (18, 18, 3, '6:41 AM', '4:00 PM', '9/8/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (19, 19, 4, '2:31 AM', '4:50 PM', '5/1/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (20, 20, 5, '6:41 AM', '3:32 PM', '9/23/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (21, 21, 6, '2:19 AM', '3:04 PM', '7/16/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (22, 22, 7, '4:05 AM', '3:43 PM', '2/26/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (23, 23, 8, '12:43 AM', '4:38 PM', '3/8/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (24, 24, 9, '6:57 AM', '3:03 PM', '8/17/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (25, 25, 10, '4:59 AM', '3:59 PM', '7/23/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (26, 26, 11, '7:07 AM', '3:57 PM', '6/15/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (27, 27, 12, '5:18 AM', '3:08 PM', '8/6/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (28, 28, 13, '7:37 AM', '3:47 PM', '1/15/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (29, 29, 14, '6:46 AM', '5:37 PM', '10/22/2025');
insert into shift (shift_id, staff_id, branch_id, shift_start, shift_end, shift_date) values (30, 30, 15, '3:16 AM', '3:03 PM', '12/24/2024');

insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (1, 1, 1998, 'Maxima', 'ABC123', 'Slovenia', '19VDE1F52DE111277', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (2, 2, 2005, 'C-Class', 'XYZ789', 'Greece', 'JTEBU5JR4A5787204', '5/11/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (3, 3, 2003, 'FX', 'DEF456', 'Italy', 'SAJWA0HP7EM543906', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (4, 4, 1994, 'Silhouette', 'GHI789', 'Estonia', '1G6AL5SX1D0875213', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (5, 5, 1992, 'Familia', 'JKL321', 'Estonia', 'JM1DE1KY8D0197193', '8/20/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (6, 6, 1998, 'Skylark', 'MNO654', 'Portugal', 'SCFAB01A87G504563', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (7, 7, 2007, 'XLR-V', 'PQR987', 'Serbia', '1G4PS5SK1D4166770', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (8, 8, 2002, 'Accord', 'STU246', 'Serbia', '1G6DF5EY3B0971334', '2/2/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (9, 9, 2012, 'Malibu', 'VWX135', 'Austria', '5N1AZ2MH1FN745272', '4/2/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (10, 10, 2001, 'E-Class', 'YZA468', 'Sweden', '1G6KD57Y18U672310', '12/20/2024');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (11, 11, 2005, 'H2', 'BCD792', 'Hungary', '1G4HP52K454377095', '9/21/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (12, 12, 2008, 'Legacy', 'EFG135', 'Ireland', '3C4PDDEG5DT679191', '6/17/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (13, 13, 1994, 'Rodeo', 'HIJ468', 'Greece', '19UUA66264A207553', '7/26/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (14, 14, 2005, 'Phantom', 'KLM792', 'Slovenia', 'WBAWB73598P583379', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (15, 15, 1993, 'Astro', 'NOP135', 'Czech Republic', 'JN1AJ0HP3BM313089', '4/22/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (16, 16, 2006, 'Zephyr', 'QRS468', 'Slovakia', 'SALVN2BG3DH691179', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (17, 17, 2008, 'Patriot', 'TUV792', 'Serbia', 'WBABW53474P135845', '8/30/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (18, 18, 1989, '200', 'WXY135', 'Italy', 'SCBLC43F25C612818', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (19, 19, 1995, '90', 'ZAB468', 'Slovakia', '1FMJU1H58AE768983', '12/12/2024');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (20, 20, 1992, 'Ram Van B350', 'CDE792', 'Slovakia', '1G6AE5S33D0143575', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (21, 21, 1995, 'Ranger', 'FGH135', 'Spain', '5FRYD4H43EB162346', '11/13/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (22, 22, 1995, 'M3', 'IJK468', 'Spain', '5N1AN0NW7DN732570', '12/25/2024');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (23, 23, 1993, 'LeBaron', 'LMN792', 'Estonia', '1N6AD0CU9AC330255', '1/15/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (24, 24, 2008, 'Edge', 'OPQ135', 'Portugal', '1FBNE3BL7BD853637', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (25, 25, 1995, 'Seville', 'RST468', 'Finland', '5UXFG8C5XDL042528', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (26, 26, 2011, 'E350', 'UVW792', 'Lithuania', 'KMHCM3AC7AU431226', '3/23/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (27, 27, 1995, 'G', 'XYZ135', 'Czech Republic', '1G6KD57Y79U869743', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (28, 28, 2011, 'Savana 2500', 'ABC468', 'Norway', 'JH4KC1F77EC424421', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (29, 29, 2004, 'Montana', 'DEF792', 'Latvia', 'JTHBE1BL9FA247896', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (30, 30, 1992, 'Mirage', 'GHI135', 'Finland', 'SCBLF34F94C428507', '8/20/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (31, 31, 2010, 'Impreza WRX', 'JKL468', 'Norway', '1N6AA0EC4DN855231', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (32, 32, 2004, 'Savana 3500', 'MNO792', 'Hungary', 'SAJWA1CB1CL623884', '10/28/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (33, 33, 2006, 'Swift', 'PQR135', 'Latvia', 'WBAYE4C54ED042865', '6/11/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (34, 34, 1985, '6000', 'STU468', 'Portugal', 'WBA3N7C57FK512010', '12/11/2024');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (35, 35, 2011, 'Equator', 'VWX792', 'Slovakia', 'WBALM7C5XCE645180', '3/15/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (36, 36, 2009, 'Sierra 1500', 'YZA135', 'Ireland', 'WDDGF5EB6BR606623', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (37, 37, 2002, 'Tacoma', 'BCD468', 'Poland', 'JN1AZ4FH4FM940563', '1/20/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (38, 38, 1991, 'E-Series', 'EFG792', 'Romania', 'KM8NU4CC5AU935947', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (39, 39, 2002, 'Cougar', 'HIJ135', 'Serbia', '1G6AA5RA3D0775315', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (40, 40, 2006, 'Daewoo Lacetti', 'KLM468', 'Sweden', '1N6AF0KY7EN472659', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (41, 41, 1992, 'LeBaron', 'NOP792', 'Croatia', 'WBAWB3C55AP096811', '2/14/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (42, 42, 2006, 'Golf', 'QRS135', 'Bulgaria', 'WBXPC93418W243109', '11/13/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (43, 43, 2006, 'Arnage', 'TUV468', 'Bulgaria', 'WBAGL63515D438166', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (44, 44, 2009, 'Santa Fe', 'WXY792', 'Finland', 'WBA5B1C50FG250073', '1/12/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (45, 45, 2008, 'Ridgeline', 'ZAB135', 'Portugal', '1ZVBP8JS5B5201656', '1/27/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (46, 46, 2005, 'Express 2500', 'CDE468', 'Lithuania', '3FA6P0SU1FR289622', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (47, 47, 2002, 'RSX', 'FGH792', 'Ireland', '1FMJK1H57EE349647', '9/30/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (48, 48, 1995, 'Metro', 'IJK135', 'Germany', 'WBAFZ9C58DC126667', '9/9/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (49, 49, 1985, '626', 'LMN468', 'Latvia', '2V4RW3D18AR787920', '8/14/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (50, 50, 2012, 'Versa', 'OPQ792', 'Norway', 'WBABV13435J035659', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (51, 1, 1973, 'Mustang', 'RST135', 'Slovenia', '2FMDK3AK1BB643545', '1/22/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (52, 2, 2006, 'Camry Solara', 'UVW468', 'Italy', 'WBAPL3C55AA154372', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (53, 3, 1993, 'W201', 'XYZ792', 'Serbia', 'WBA1J7C54EV035326', '2/6/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (54, 4, 1995, 'Town & Country', 'ABC135', 'Latvia', 'WBSBR93406P431044', '8/14/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (55, 5, 2010, 'New Beetle', 'DEF468', 'Malta', '1B3CB2HAXAD914400', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (56, 6, 2011, 'Silverado', 'GHI792', 'Denmark', '1GTN2TEHXFZ266341', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (57, 7, 2009, 'Silverado 3500', 'JKL135', 'Latvia', '3MZBM1K75EM999732', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (58, 8, 2012, 'Express 2500', 'MNO468', 'Latvia', 'WP0AB2A99AS010989', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (59, 9, 1967, 'Falcon', 'PQR792', 'Italy', 'WBAFR7C53DC210304', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (60, 10, 2012, 'Avalanche', 'STU135', 'Norway', '1FTMF1EW9AF087735', null);
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (61, 11, 2007, 'Durango', 'VWX468', 'Norway', '2C3CA3CV7AH456761', '4/12/2025');
insert into vehicle (vehicle_id, customer_id, car_year, car_model, car_reg, car_origin, VIN, mot_date) values (62, 12, 2002, 'rio', 'YZA792', 'Belgium', '1GYS4CKJ3FR718869', null);

insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (1, 1, 'Jerome', 'McGeady', '283-598-0360', 'Suite 1');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (2, 2, 'Adrian', 'Venneur', '951-176-4815', 'PO Box 18164');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (3, 3, 'Nikolaus', 'Tuffley', '666-322-1714', 'Suite 12');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (4, 4, 'Philippe', 'O''Hartigan', '196-175-5204', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (5, 5, 'Isidore', 'Persse', '676-241-9038', 'Apt 1192');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (6, 6, 'Jeniffer', 'Rouff', '175-140-5052', 'Apt 1428');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (7, 7, 'Peter', 'Sulley', '920-607-6594', 'PO Box 60796');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (8, 8, 'Israel', 'Wooderson', '227-495-5975', 'PO Box 30542');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (9, 9, 'Berny', 'Tranfield', '447-229-8664', 'Apt 331');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (10, 10, 'Wain', 'Rowet', '865-463-2054', 'Suite 98');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (11, 11, 'Ashley', 'Tinton', '164-789-8767', 'PO Box 72228');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (12, 12, 'Ulrich', 'Ledson', '744-418-4296', 'PO Box 10603');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (13, 13, 'Crista', 'Simonelli', '990-450-6486', 'Suite 94');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (14, 14, 'Lucila', 'Barclay', '375-841-1773', 'Apt 968');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (15, 15, 'Kessia', 'Clowney', '960-780-6678', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (16, 16, 'Nari', 'Kitchener', '745-741-8163', 'PO Box 39077');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (17, 17, 'Cassey', 'O''Dempsey', '579-458-6704', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (18, 18, 'Marlow', 'Harly', '156-742-9764', 'Suite 78');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (19, 19, 'Efren', 'Purry', '918-795-0728', 'Apt 1917');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (20, 20, 'Sumner', 'Watting', '972-936-4103', 'Apt 1347');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (21, 21, 'Shalna', 'Ohm', '536-351-1799', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (22, 22, 'Yorgos', 'Desport', '805-704-9709', 'Apt 1088');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (23, 23, 'Sacha', 'Oakshott', '707-968-1304', 'PO Box 84078');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (24, 24, 'Findlay', 'MacCaffrey', '351-688-8036', 'PO Box 32472');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (25, 25, 'Harriet', 'Pirot', '909-873-3998', 'PO Box 86523');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (26, 26, 'Christopher', 'Caldaro', '260-544-8410', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (27, 27, 'Hanna', 'Merrigans', '596-323-1014', 'Suite 19');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (28, 28, 'Kaitlyn', 'Barens', '128-894-1002', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (29, 29, 'Lyda', 'Fowlestone', '199-407-7810', 'Apt 1360');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (30, 30, 'Carlos', 'Jarret', '504-273-6919', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (31, 31, 'Jany', 'Marson', '465-516-4821', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (32, 32, 'Dotty', 'Blakesley', '963-638-6804', 'Room 310');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (33, 33, 'Candace', 'Crannage', '335-418-7008', 'Room 725');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (34, 34, 'Irma', 'Ben', '945-178-0321', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (35, 35, 'Amata', 'Guild', '165-486-6293', '15th Floor');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (36, 36, 'Homer', 'Whisby', '237-908-8552', '9th Floor');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (37, 37, 'Alfy', 'Vaggers', '133-562-5326', 'Apt 510');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (38, 38, 'Che', 'Medcraft', '418-549-2863', 'Suite 6');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (39, 39, 'Tiebold', 'Archibold', '642-914-9792', 'PO Box 56195');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (40, 40, 'Tracey', 'Crowcombe', '849-616-3672', '16th Floor');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (41, 41, 'Kiel', 'Ashford', '111-721-2388', 'Apt 1487');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (42, 42, 'Finley', 'Kopfer', '428-980-0247', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (43, 43, 'Debby', 'Quest', '826-107-2013', 'PO Box 83680');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (44, 44, 'Nissy', 'Gregori', '702-789-4218', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (45, 45, 'Brantley', 'Greatbach', '398-606-7169', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (46, 46, 'Mord', 'McDermott', '817-724-8309', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (47, 47, 'Aeriela', 'Addison', '871-952-4311', 'Apt 702');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (48, 48, 'Issie', 'Amiss', '217-807-4999', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (49, 49, 'Lorant', 'Macvain', '221-389-4553', 'Apt 1780');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (50, 50, 'Yvon', 'Austing', '284-663-2240', 'PO Box 34149');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (51, 1, 'Rochelle', 'Bonnier', '332-730-8656', '4th Floor');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (52, 2, 'Marney', 'Rozanski', '717-251-2955', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (53, 3, 'Jermaine', 'Baynom', '221-313-0448', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (54, 4, 'Elfrida', 'Wileman', '504-366-9049', 'Apt 1819');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (55, 5, 'Ram', 'Creed', '670-749-0127', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (56, 6, 'Chrissie', 'Bernaldo', '848-504-1026', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (57, 7, 'Darryl', 'Dowber', '341-436-6095', '5th Floor');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (58, 8, 'Germana', 'Fogel', '754-238-3870', null);
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (59, 9, 'Bria', 'Perkin', '983-769-5219', 'Apt 1641');
insert into emergencycontact (contact_id, customer_id, contact_fname, contact_lname, contact_phone, contact_address) values (60, 10, 'Donny', 'Kaaskooper', '636-864-8577', 'PO Box 73060');

insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (1, 1, 1, 1, '11/27/2025', '9:26 PM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (2, 2, 2, 2,  '4/9/2025', '6:34 AM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (3, 3, 3, 3, '9/3/2025', '1:02 AM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (4, 4, 4, 4, '2/26/2025', '8:04 PM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (5, 5, 5, 5, '12/5/2024', '5:00 AM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (6, 6, 6, 6, '3/28/2025', '1:18 AM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (7, 7, 7, 7, '1/14/2025', '2:54 PM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (8, 8, 8, 8, '5/3/2025', '4:20 PM', 'Completed');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (9, 9, 9, 9, '9/5/2025', '9:48 AM', 'Completed');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (10, 10, 10, 10, '10/9/2025', '7:23 PM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (11, 11, 11, 11, '3/7/2025', '8:42 AM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (12, 12, 12, 12, '6/5/2025', '6:47 AM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (13, 13, 13, 13, '8/16/2025', '3:46 AM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (14, 14, 14, 14, '5/14/2025', '12:03 AM', 'Completed');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (15, 15, 15, 15, '10/30/2025', '1:50 AM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (16, 16, 16, 1,  '5/4/2025', '1:10 PM', 'Completed');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (17, 17, 17, 2, '2/15/2025', '1:21 PM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (18, 18, 18, 3, '10/16/2025', '1:26 PM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (19, 19, 19, 4, '11/11/2025', '5:06 PM', 'Completed');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (20, 20, 20, 5, '5/5/2025', '10:35 PM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (21, 21, 21, 6,  '6/25/2025', '4:10 AM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (22, 22, 22, 7,  '2/9/2025', '3:26 PM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (23, 23, 23, 8,  '9/25/2025', '8:35 PM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (24, 24, 24, 9,  '12/31/2024', '5:00 AM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (25, 25, 25, 10,  '5/23/2025', '2:45 PM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (26, 26, 26, 11,  '4/10/2025', '11:27 PM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (27, 27, 27, 12,  '5/2/2025', '4:56 PM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (28, 28, 28, 13,  '7/20/2025', '9:23 AM', 'Completed');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (29, 29, 29, 14,  '3/28/2025', '12:52 PM', 'Completed');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (30, 30, 30, 15,  '2/17/2025', '11:36 PM', 'Completed');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (31, 31, 31, 1,  '7/25/2025', '8:13 AM', 'Completed');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (32, 32, 32, 2,  '4/24/2025', '2:29 AM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (33, 33, 33, 3,  '4/21/2025', '3:37 AM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (34, 34, 34, 4,  '11/23/2025', '10:37 AM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (35, 35, 35, 5,  '3/28/2025', '1:14 AM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (36, 36, 36, 6,  '6/14/2025', '10:51 AM', 'Completed');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (37, 37, 37, 7,  '10/8/2025', '12:30 AM', 'Completed');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (38, 38, 38, 8,  '6/27/2025', '3:19 AM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (39, 39, 39, 9,  '8/8/2025', '7:10 PM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (40, 40, 40, 10,  '12/21/2024', '5:28 AM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (41, 41, 41, 11,  '5/10/2025', '12:19 AM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (42, 42, 42, 12,  '9/12/2025', '3:35 AM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (43, 43, 43, 13,  '2/18/2025', '7:06 AM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (44, 44, 44, 14,  '9/7/2025', '3:30 PM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (45, 45, 45, 15,  '11/20/2025', '6:15 PM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (46, 46, 46, 1,  '1/30/2025', '7:54 PM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (47, 47, 47, 2,  '3/1/2025', '8:37 PM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (48, 48, 48, 3,  '4/27/2025', '6:30 PM', 'Completed');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (49, 49, 49, 4,  '4/6/2025', '1:14 AM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (50, 50, 50, 5,  '12/21/2024', '3:52 PM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (51, 1, 51, 6,  '1/8/2025', '6:52 AM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (52, 2, 52, 7,  '6/5/2025', '1:14 AM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (53, 3, 53, 8,  '4/23/2025', '4:41 AM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (54, 4, 54, 9,  '12/25/2024', '12:48 PM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (55, 5, 55, 10,  '8/8/2025', '9:02 PM', 'Scheduled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (56, 6, 56, 11,  '1/2/2025', '3:10 AM', 'Completed');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (57, 7, 57, 12,  '2/26/2025', '6:06 AM', 'Completed');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (58, 8, 58, 13,  '10/23/2025', '7:35 AM', 'Completed');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (59, 9, 59, 14,  '2/20/2025', '10:31 AM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (60, 10, 60, 15,  '8/25/2025', '10:45 PM', 'Completed');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (61, 11, 61, 1,  '2/4/2025', '6:00 PM', 'Cancelled');
insert into booking (booking_id, customer_id, vehicle_id, branch_id, booking_date, scheduled_time, booking_status) values (62, 12, 62, 2, '11/29/2025', '3:04 AM', 'Cancelled');

insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (1, 49, 5, 18, 'Pending', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (2, 1, 2, 7, 'Completed', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (3, 6, 1, 12, 'Completed', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (4, 50, 7, 1, 'Pending', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (5, 43, 1, 24, 'Pending', null);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (6, 15, 6, 18, 'In Progress', 4);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (7, 15, 4, 2, 'Completed', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (8, 34, 1, 17, 'Completed', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (9, 15, 2, 3, 'Completed', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (10, 16, 9, 1, 'In Progress', 1.5);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (11, 49, 6, 28, 'Completed', 4);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (12, 32, 7, 30, 'Completed', 4);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (13, 50, 5, 21, 'In Progress', 5.5);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (14, 20, 9, 23, 'Completed', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (15, 38, 9, 30, 'Completed', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (16, 45, 3, 3, 'Completed', 15);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (17, 47, 9, 7, 'Completed', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (18, 43, 4, 23, 'Completed', null);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (19, 7, 1, 23, 'Pending', null);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (20, 9, 3, 18, 'Completed', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (21, 41, 7, 11, 'In Progress', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (22, 16, 7, 16, 'Completed', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (23, 46, 6, 4, 'Completed', 1.5);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (24, 1, 4, 7, 'Pending', 1.5);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (25, 7, 1, 9, 'Completed', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (26, 49, 7, 16, 'In Progress', null);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (27, 2, 1, 13, 'Pending', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (28, 18, 1, 11, 'Completed', 1.5);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (29, 47, 2, 1, 'Completed', 1.5);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (30, 43, 8, 24, 'Completed', 12);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (31, 24, 4, 12, 'In Progress', null);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (32, 29, 9, 27, 'Completed', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (33, 47, 4, 20, 'Pending', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (34, 19, 7, 22, 'Pending', null);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (35, 34, 2, 5, 'Pending', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (36, 35, 10, 15, 'In Progress', 12);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (37, 40, 1, 25, 'Completed', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (38, 25, 2, 10, 'Pending', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (39, 26, 2, 14, 'In Progress', 3);
insert into task (task_id, booking_id, service_id, staff_id, task_status, time_taken) values (40, 9, 6, 16, 'Pending', 12);

insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (1, 1, 1, 1, 1);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (2, 2, 2, 2, 2);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (3, 3, 3, 3, 3);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (4, 4, 4, 4, 4);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (5, 5, 5, 5, 5);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (6, 6, 6, 6, 6);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (7, 7, 7, 7, 7);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (8, 8, 8, 8, 8);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (9, 9, 9, 9, 9);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (10, 10, 10, 10, 10);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (11, 11, 11, 11, 11);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (12, 12, 12, 12, 12);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (13, 13, 13, 13, 13);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (14, 14, 14, 14, 14);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (15, 15, 15, 15, 15);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (16, 16, 16, 16, 16);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (17, 17, 17, 17, 17);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (18, 18, 18, 18, 18);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (19, 19, 19, 19, 19);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (20, 20, 20, 20, 20);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (21, 21, 21, 21, 21);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (22, 22, 22, 22, 22);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (23, 23, 23, 23, 23);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (24, 24, 24, 24, 24);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (25, 25, 25, 25, 25);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (26, 26, 26, 26, 26);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (27, 27, 27, 27, 27);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (28, 28, 28, 28, 28);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (29, 29, 29, 29, 29);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (30, 30, 30, 30, 30);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (31, 31, 31, 31, 1);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (32, 32, 32, 32, 2);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (33, 33, 33, 33, 3);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (34, 34, 34, 34, 4);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (35, 35, 35, 35, 5);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (36, 36, 36, 36, 6);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (37, 37, 37, 37, 7);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (38, 38, 38, 38, 8);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (39, 39, 39, 39, 9);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (40, 40, 40, 40, 10);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (41, 41, 41, 41, 11);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (42, 42, 42, 42, 12);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (43, 43, 43, 43, 13);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (44, 44, 44, 44, 14);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (45, 45, 45, 45, 15);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (46, 46, 46, 46, 16);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (47, 47, 47, 47, 17);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (48, 48, 48, 48, 18);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (49, 49, 49, 49, 19);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (50, 50, 50, 50, 20);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (51, 51, 51, 1, 21);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (52, 52, 52, 2, 22);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (53, 53, 53, 3, 23);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (54, 54, 54, 4, 24);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (55, 55, 55, 5, 25);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (56, 56, 56, 6, 26);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (57, 57, 57, 7, 27);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (58, 58, 58, 8, 28);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (59, 59, 59, 9, 29);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (60, 60, 60, 10, 30);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (61, 61, 61, 11, 1);
insert into VehicleAllocation (allocation_id, vehicle_id, booking_id, bay_id, staff_id) values (62, 62, 62, 12, 2);

insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (1, 1, 195.62, 'Due', '6/23/2025', '4/30/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (2, 2, 71.6, 'Paid', '4/29/2025', '6/20/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (3, 3, 134.5, 'Overdue', '8/18/2025', '2/16/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (4, 4, 65.5, 'Partially Paid', '9/12/2025', '6/13/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (5, 5, 197.71, 'Due', '2/21/2025', '9/9/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (6, 6, 52.0, 'Paid', '8/30/2025', '7/15/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (7, 7, 189.48, 'Overdue', '5/6/2025', '2/16/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (8, 8, 131.2, 'Partially Paid', '2/17/2025', '10/30/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (9, 9, 62.29, 'Due', '3/26/2025', '9/4/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (10, 10, 61.21, 'Paid', '11/12/2025', '9/27/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (11, 11, 177.31, 'Overdue', '10/19/2025', '3/24/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (12, 12, 149.04, 'Partially Paid', '9/8/2025', '8/9/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (13, 13, 132.48, 'Due', '4/1/2025', '3/1/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (14, 14, 72.76, 'Paid', '1/16/2025', '8/27/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (15, 15, 63.66, 'Overdue', '10/21/2025', '1/28/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (16, 16, 110.43, 'Partially Paid', '12/31/2024', '7/14/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (17, 17, 154.99, 'Due', '1/10/2025', '8/23/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (18, 18, 61.91, 'Paid', '4/18/2025', '11/9/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (19, 19, 156.16, 'Overdue', '5/19/2025', '4/26/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (20, 20, 146.23, 'Partially Paid', '9/21/2025', '2/19/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (21, 21, 125.23, 'Due', '1/27/2025', '12/4/2025');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (22, 22, 94.48, 'Paid', '10/1/2025', '2/21/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (23, 23, 157.14, 'Overdue', '4/3/2025', '6/10/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (24, 24, 103.29, 'Partially Paid', '3/25/2025', '7/20/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (25, 25, 101.0, 'Due', '4/29/2025', '6/13/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (26, 26, 93.29, 'Paid', '8/18/2025', '6/5/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (27, 27, 95.96, 'Overdue', '8/21/2025', '2/13/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (28, 28, 97.59, 'Partially Paid', '12/21/2024', '4/30/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (29, 29, 131.28, 'Due', '6/19/2025', '10/19/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (30, 30, 130.86, 'Paid', '3/9/2025', '5/23/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (31, 31, 90.23, 'Overdue', '9/12/2025', '7/10/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (32, 32, 100.32, 'Partially Paid', '11/27/2025', '5/12/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (33, 33, 116.68, 'Due', '1/3/2025', '1/11/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (34, 34, 174.14, 'Paid', '12/29/2024', '9/5/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (35, 35, 182.26, 'Overdue', '7/23/2025', '6/4/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (36, 36, 123.6, 'Partially Paid', '3/28/2025', '8/29/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (37, 37, 63.09, 'Due', '12/11/2024', '12/25/2025');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (38, 38, 174.7, 'Paid', '1/11/2025', '5/2/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (39, 39, 169.6, 'Overdue', '8/21/2025', '6/4/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (40, 40, 93.39, 'Partially Paid', '10/29/2025', '9/18/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (41, 41, 148.08, 'Due', '9/20/2025', '5/11/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (42, 42, 177.78, 'Paid', '11/28/2025', '2/25/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (43, 43, 77.73, 'Overdue', '8/19/2025', '11/17/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (44, 44, 110.71, 'Partially Paid', '12/9/2024', '2/1/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (45, 45, 90.69, 'Due', '12/24/2024', '4/5/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (46, 46, 89.4, 'Paid', '6/25/2025', '11/23/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (47, 47, 194.36, 'Overdue', '4/30/2025', '12/26/2025');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (48, 48, 146.06, 'Partially Paid', '12/20/2024', '12/7/2025');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (49, 49, 190.87, 'Due', '3/29/2025', '1/20/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (50, 50, 92.9, 'Paid', '3/28/2025', '5/28/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (51, 51, 151.97, 'Overdue', '2/23/2025', '12/26/2025');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (52, 52, 103.81, 'Partially Paid', '9/20/2025', '5/3/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (53, 53, 51.46, 'Due', '3/30/2025', '5/31/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (54, 54, 113.45, 'Paid', '9/10/2025', '1/31/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (55, 55, 160.88, 'Overdue', '12/21/2024', '9/1/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (56, 56, 116.66, 'Partially Paid', '12/25/2024', '11/8/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (57, 57, 176.0, 'Due', '10/3/2025', '11/8/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (58, 58, 164.25, 'Paid', '4/4/2025', '2/16/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (59, 59, 110.61, 'Overdue', '11/15/2025', '12/25/2025');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (60, 60, 167.24, 'Partially Paid', '8/13/2025', '6/13/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (61, 61, 122.02, 'Due', '11/7/2025', '1/21/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (62, 62, 52.4, 'Paid', '11/28/2025', '12/31/2025');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (63, 1, 54.0, 'Overdue', '7/17/2025', '7/26/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (64, 2, 73.09, 'Partially Paid', '6/1/2025', '4/17/2026');
insert into Invoice (invoice_id, booking_id, invoice_total, invoice_status, issue_date, due_date) values (65, 3, 170.04, 'Due', '5/4/2025', '12/31/2025');

insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (1, 46, 17, 'Email', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', '3/24/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (2, 37, 9, 'Phone', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', '1/23/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (3, 46, 42, 'Email', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', '12/29/2024');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (4, 20, 38, 'Email', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', '5/12/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (5, 13, 17, 'Email', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', '2/12/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (6, 45, 27, 'SMS', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', '2/13/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (7, 54, 16, 'SMS', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.', '12/20/2024');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (8, 31, 4, 'Phone', 'Fusce consequat. Nulla nisl. Nunc nisl.', '10/23/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (9, 29, 44, 'SMS', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', '6/18/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (10, 60, 19, 'SMS', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '3/3/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (11, 46, 15, 'Email', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', '5/5/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (12, 21, 29, 'Email', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', '10/25/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (13, 12, 42, 'SMS', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', '10/4/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (14, 38, 19, 'Email', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', '4/7/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (15, 33, 18, 'SMS', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', '10/11/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (16, 47, 10, 'Phone', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', '5/10/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (17, 11, 13, 'Phone', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', '6/29/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (18, 10, 13, 'Phone', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', '1/16/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (19, 42, 46, 'SMS', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', '8/29/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (20, 50, 10, 'Phone', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', '12/14/2024');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (21, 61, 6, 'Email', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', '9/15/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (22, 4, 31, 'Phone', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', '3/28/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (23, 20, 20, 'Email', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', '7/20/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (24, 28, 46, 'Email', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', '7/24/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (25, 6, 19, 'Email', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '10/24/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (26, 47, 29, 'SMS', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.', '7/29/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (27, 27, 11, 'SMS', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', '8/27/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (28, 34, 39, 'Email', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '5/5/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (29, 12, 50, 'Email', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', '11/2/2025');
insert into CommunicationLog (log_id, booking_id, customer_id, channel, message_content, date_sent) values (30, 21, 34, 'Phone', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', '6/28/2025');

insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (1, 37, 1, 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', '10/21/2025', 'Open', null, 23);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (2, 15, 1, null, '10/13/2025', 'In Progress', null, 21);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (3, 40, 2, null, '11/14/2025', 'Resolved', null, 6);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (4, 35, 1, null, '12/2/2024', 'Open', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.', 29);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (5, 36, 1, null, '3/12/2025', 'In Progress', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 11);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (6, 1, 5, null, '12/22/2024', 'Resolved', 'Fusce consequat. Nulla nisl. Nunc nisl.', 22);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (7, 48, 4, 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', '10/14/2025', 'Open', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', 24);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (8, 52, 1, 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '11/14/2025', 'In Progress', null, 21);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (9, 44, 1, null, '9/14/2025', 'Resolved', null, 28);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (10, 14, 4, 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', '1/5/2025', 'Open', null, 16);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (11, 55, 5, 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', '4/19/2025', 'In Progress', null, 30);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (12, 23, 4, 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', '6/3/2025', 'Resolved', 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 12);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (13, 2, 1, null, '11/24/2025', 'Open', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.', 30);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (14, 38, 1, 'Phasellus in felis. Donec semper sapien a libero. Nam dui.', '9/16/2025', 'In Progress', null, 9);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (15, 53, 4, 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', '7/18/2025', 'Resolved', null, 14);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (16, 41, 5, 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', '3/21/2025', 'Open', null, 8);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (17, 50, 1, null, '12/1/2024', 'In Progress', null, 9);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (18, 32, 2, null, '11/17/2025', 'Resolved', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 26);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (19, 37, 5, null, '5/15/2025', 'Open', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', 15);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (20, 21, 1, 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', '5/25/2025', 'In Progress', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 21);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (21, 28, 3, 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', '8/12/2025', 'Resolved', null, 1);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (22, 28, 2, null, '9/27/2025', 'Open', null, 21);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (23, 47, 1, 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', '12/10/2024', 'In Progress', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', 22);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (24, 16, 5, null, '2/3/2025', 'Resolved', null, 20);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (25, 6, 3, null, '3/24/2025', 'Open', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 22);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (26, 28, 2, null, '8/23/2025', 'In Progress', null, 26);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (27, 3, 4, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '12/18/2024', 'Resolved', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', 20);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (28, 15, 1, null, '11/23/2025', 'Open', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', 20);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (29, 36, 3, 'Fusce consequat. Nulla nisl. Nunc nisl.', '3/31/2025', 'In Progress', null, 30);
insert into Feedback (feedback_id, booking_id, rating, feedback_desc, feedback_date, resolution_status, resolution_desc, resolved_by_staff) values (30, 34, 2, null, '10/1/2025', 'Resolved', null, 29);

insert into Usage (usage_id, task_id, part_id, quantity_used) values (1, 23, 41, 67);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (2, 7, 49, 29);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (3, 38, 11, 19);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (4, 15, 45, 2);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (5, 40, 22, 34);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (6, 28, 38, 68);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (7, 38, 28, 33);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (8, 21, 11, 27);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (9, 8, 19, 46);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (10, 8, 39, 98);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (11, 24, 25, 38);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (12, 15, 5, 34);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (13, 30, 5, 65);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (14, 26, 43, 78);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (15, 30, 46, 76);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (16, 18, 51, 83);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (17, 11, 39, 10);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (18, 25, 28, 74);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (19, 26, 26, 27);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (20, 1, 9, 42);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (21, 34, 38, 71);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (22, 22, 39, 36);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (23, 39, 51, 47);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (24, 15, 42, 99);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (25, 33, 34, 35);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (26, 40, 32, 65);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (27, 9, 46, 16);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (28, 13, 16, 74);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (29, 28, 24, 78);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (30, 21, 26, 42);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (31, 19, 22, 45);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (32, 35, 35, 1);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (33, 5, 5, 85);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (34, 11, 11, 51);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (35, 1, 30, 1);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (36, 35, 34, 49);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (37, 32, 27, 53);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (38, 26, 17, 56);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (39, 37, 10, 26);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (40, 26, 3, 41);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (41, 25, 31, 18);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (42, 40, 6, 71);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (43, 12, 32, 28);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (44, 11, 21, 75);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (45, 25, 34, 43);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (46, 10, 44, 88);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (47, 39, 20, 55);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (48, 35, 29, 88);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (49, 1, 28, 77);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (50, 26, 22, 65);
insert into Usage (usage_id, task_id, part_id, quantity_used) values (51, 17, 14, 23);

insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (1, 1, '10/4/2025', 856.14, 'Cash', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (2, 2, '10/11/2025', 258.19, 'Bank Transfer', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (3, 3, '11/3/2025', 334.31, 'Cash', 'Partial');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (4, 4, '4/5/2025', 432.22, 'Debit Card', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (5, 5, '12/13/2024', 909.7, 'Bank Transfer', 'Partial');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (6, 6, '3/7/2025', 538.37, 'Debit Card', 'Partial');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (7, 7, '1/27/2025', 442.89, 'Credit Card', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (8, 8, '1/28/2025', 526.71, 'Credit Card', 'Partial');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (9, 9, '10/6/2025', 219.83, 'Debit Card', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (10, 10, '2/25/2025', 368.9, 'Credit Card', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (11, 11, '8/25/2025', 152.16, 'Credit Card', 'Partial');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (12, 12, '5/5/2025', 664.82, 'Bank Transfer', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (13, 13, '1/26/2025', 161.57, 'Cash', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (14, 14, '7/24/2025', 300.06, 'Credit Card', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (15, 15, '9/5/2025', 160.34, 'Bank Transfer', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (16, 16, '2/18/2025', 713.71, 'Cash', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (17, 17, '4/19/2025', 589.53, 'Cash', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (18, 18, '3/31/2025', 371.4, 'Credit Card', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (19, 19, '4/1/2025', 248.98, 'Credit Card', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (20, 20, '2/8/2025', 919.44, 'Debit Card', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (21, 21, '2/14/2025', 776.29, 'Bank Transfer', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (22, 22, '2/9/2025', 172.41, 'Debit Card', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (23, 23, '10/3/2025', 778.04, 'Cash', 'Partial');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (24, 24, '11/17/2025', 358.16, 'Cash', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (25, 25, '6/17/2025', 625.81, 'Credit Card', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (26, 26, '1/2/2025', 207.18, 'Debit Card', 'Partial');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (27, 27, '7/1/2025', 793.36, 'Cash', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (28, 28, '11/9/2025', 871.43, 'Debit Card', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (29, 29, '5/16/2025', 246.83, 'Credit Card', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (30, 30, '1/31/2025', 137.5, 'Debit Card', 'Partial');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (31, 31, '9/10/2025', 694.52, 'Bank Transfer', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (32, 32, '12/11/2024', 972.32, 'Cash', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (33, 33, '7/1/2025', 818.74, 'Debit Card', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (34, 34, '3/30/2025', 627.71, 'Debit Card', 'Partial');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (35, 35, '10/11/2025', 679.83, 'Debit Card', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (36, 36, '6/14/2025', 708.49, 'Cash', 'Partial');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (37, 37, '5/12/2025', 934.8, 'Credit Card', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (38, 38, '10/1/2025', 117.97, 'Debit Card', 'Partial');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (39, 39, '3/16/2025', 976.98, 'Bank Transfer', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (40, 40, '11/20/2025', 777.12, 'Bank Transfer', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (41, 41, '6/2/2025', 908.06, 'Bank Transfer', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (42, 42, '1/28/2025', 626.04, 'Credit Card', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (43, 43, '10/2/2025', 367.92, 'Cash', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (44, 44, '8/21/2025', 743.57, 'Debit Card', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (45, 45, '9/21/2025', 835.86, 'Debit Card', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (46, 46, '3/23/2025', 134.62, 'Cash', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (47, 47, '3/2/2025', 862.7, 'Debit Card', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (48, 48, '10/19/2025', 522.96, 'Cash', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (49, 49, '11/2/2025', 431.43, 'Debit Card', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (50, 50, '9/25/2025', 252.69, 'Debit Card', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (51, 51, '6/1/2025', 550.92, 'Credit Card', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (52, 52, '3/29/2025', 903.19, 'Debit Card', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (53, 53, '1/9/2025', 212.47, 'Debit Card', 'Partial');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (54, 54, '6/7/2025', 671.95, 'Bank Transfer', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (55, 55, '5/28/2025', 550.41, 'Credit Card', 'Partial');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (56, 56, '3/27/2025', 415.9, 'Debit Card', 'Partial');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (57, 57, '1/24/2025', 961.04, 'Credit Card', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (58, 58, '4/22/2025', 666.82, 'Cash', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (59, 59, '3/29/2025', 199.15, 'Cash', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (60, 60, '11/10/2025', 821.03, 'Bank Transfer', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (61, 61, '7/16/2025', 838.41, 'Credit Card', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (62, 62, '11/9/2025', 511.1, 'Debit Card', 'Partial');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (63, 63, '3/28/2025', 177.02, 'Debit Card', 'Refund');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (64, 64, '9/21/2025', 801.39, 'Bank Transfer', 'Full');
insert into Payment (payment_id, invoice_id, payment_date, payment_amount, payment_method, transaction_type) values (65, 65, '6/18/2025', 548.42, 'Cash', 'Partial');

insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (1, 'Bay Inspection', '11/25/2025', 'Processing', 29, 7, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (2, 'Certification', '8/6/2025', 'Fail', 22, null, 55);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (3, 'MOT', '5/17/2025', 'Cancelled', 13, null, 29);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (4, 'IVA', '11/2/2025', 'Processing', 2, null, 3);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (5, 'Certification', '8/27/2025', 'Fail', 3, null, 50);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (6, 'Bay Inspection', '7/18/2025', 'Fail', 17, 6, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (7, 'Bay Inspection', '10/1/2025', 'Fail', 11, 10, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (8, 'MOT', '8/15/2025', 'Processing', 18, null, 47);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (9, 'IVA', '8/14/2025', 'Processing', 13, null, 24);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (10, 'Certification', '2/16/2025', 'Pass', 9, NULL, 60);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (11, 'Bay Inspection', '6/26/2025', 'Processing', 4, 13, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (12, 'MOT', '6/3/2025', 'Cancelled', 13, null, 24);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (13, 'MOT', '11/29/2025', 'Cancelled', 2, null, 49);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (14, 'LOLER', '7/31/2025', 'Fail', 21, 4, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (15, 'LOLER', '12/22/2024', 'Fail', 24, 4, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (16, 'Certification', '1/28/2025', 'Fail', 15, null, 6);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (17, 'Certification', '12/11/2024', 'Processing', 6, null, 50);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (18, 'MOT', '4/18/2025', 'Processing', 3, null, 9);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (19, 'LOLER', '9/18/2025', 'Cancelled', 22, 4, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (20, 'Certification', '8/9/2025', 'Cancelled', 26, null, 59);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (21, 'Certification', '7/10/2025', 'Fail', 17, null, 25);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (22, 'MOT', '7/26/2025', 'Fail', 29, null, 10);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (23, 'Certification', '6/27/2025', 'Cancelled', 14, null, 47);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (24, 'LOLER', '5/1/2025', 'Pass', 13, 7, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (25, 'IVA', '8/2/2025', 'Pass', 25, null, 21);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (26, 'Bay Inspection', '7/30/2025', 'Pass', 28, 7, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (27, 'IVA', '2/5/2025', 'Fail', 8, null, 36);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (28, 'MOT', '3/29/2025', 'Fail', 13, null, 48);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (29, 'Bay Inspection', '12/10/2024', 'Pass', 9, 11, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (30, 'LOLER', '10/14/2025', 'Fail', 12, 12, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (31, 'IVA', '8/16/2025', 'Cancelled', 16, null, 11);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (32, 'LOLER', '3/26/2025', 'Processing', 21, 3, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (33, 'LOLER', '9/4/2025', 'Cancelled', 8, 15, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (34, 'LOLER', '10/6/2025', 'Pass', 1, 7, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (35, 'LOLER', '9/22/2025', 'Fail', 24, 12, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (36, 'IVA', '11/5/2025', 'Processing', 7, null, 29);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (37, 'Bay Inspection', '11/6/2025', 'Fail', 5, 10, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (38, 'Bay Inspection', '10/4/2025', 'Fail', 26, 12, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (39, 'MOT', '2/26/2025', 'Cancelled', 4, null, 2);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (40, 'Bay Inspection', '5/18/2025', 'Cancelled', 6, 7, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (41, 'MOT', '8/5/2025', 'Cancelled', 9, null, 45);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (42, 'Bay Inspection', '3/24/2025', 'Cancelled', 22, 10, null);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (43, 'Certification', '5/1/2025', 'Cancelled', 21, null, 13);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (44, 'IVA', '10/8/2025', 'Fail', 7, null, 57);
insert into ComplianceRecord (compliance_id, compliance_type, compliance_date, compliance_result, compliance_staff, compliance_bay, vehicle_id) values (45, 'Bay Inspection', '10/3/2025', 'Fail', 3, 12, null);

insert into BranchStock (branch_id, part_id, quantity_stock) values (1, 1, 51);
insert into BranchStock (branch_id, part_id, quantity_stock) values (2, 2, 87);
insert into BranchStock (branch_id, part_id, quantity_stock) values (3, 3, 36);
insert into BranchStock (branch_id, part_id, quantity_stock) values (4, 4, 66);
insert into BranchStock (branch_id, part_id, quantity_stock) values (5, 5, 65);
insert into BranchStock (branch_id, part_id, quantity_stock) values (6, 6, 83);
insert into BranchStock (branch_id, part_id, quantity_stock) values (7, 7, 22);
insert into BranchStock (branch_id, part_id, quantity_stock) values (8, 8, 54);
insert into BranchStock (branch_id, part_id, quantity_stock) values (9, 9, 58);
insert into BranchStock (branch_id, part_id, quantity_stock) values (10, 10, 64);
insert into BranchStock (branch_id, part_id, quantity_stock) values (11, 11, 21);
insert into BranchStock (branch_id, part_id, quantity_stock) values (12, 12, 13);
insert into BranchStock (branch_id, part_id, quantity_stock) values (13, 13, 51);
insert into BranchStock (branch_id, part_id, quantity_stock) values (14, 14, 82);
insert into BranchStock (branch_id, part_id, quantity_stock) values (15, 15, 25);
insert into BranchStock (branch_id, part_id, quantity_stock) values (1, 16, 75);
insert into BranchStock (branch_id, part_id, quantity_stock) values (2, 17, 41);
insert into BranchStock (branch_id, part_id, quantity_stock) values (3, 18, 90);
insert into BranchStock (branch_id, part_id, quantity_stock) values (4, 19, 68);
insert into BranchStock (branch_id, part_id, quantity_stock) values (5, 20, 23);
insert into BranchStock (branch_id, part_id, quantity_stock) values (6, 21, 20);
insert into BranchStock (branch_id, part_id, quantity_stock) values (7, 22, 87);
insert into BranchStock (branch_id, part_id, quantity_stock) values (8, 23, 98);
insert into BranchStock (branch_id, part_id, quantity_stock) values (9, 24, 73);
insert into BranchStock (branch_id, part_id, quantity_stock) values (10, 25, 67);
insert into BranchStock (branch_id, part_id, quantity_stock) values (11, 26, 98);
insert into BranchStock (branch_id, part_id, quantity_stock) values (12, 27, 72);
insert into BranchStock (branch_id, part_id, quantity_stock) values (13, 28, 93);
insert into BranchStock (branch_id, part_id, quantity_stock) values (14, 29, 17);
insert into BranchStock (branch_id, part_id, quantity_stock) values (15, 30, 24);
insert into BranchStock (branch_id, part_id, quantity_stock) values (1, 31, 6);
insert into BranchStock (branch_id, part_id, quantity_stock) values (2, 32, 13);
insert into BranchStock (branch_id, part_id, quantity_stock) values (3, 33, 71);
insert into BranchStock (branch_id, part_id, quantity_stock) values (4, 34, 19);
insert into BranchStock (branch_id, part_id, quantity_stock) values (5, 35, 71);
insert into BranchStock (branch_id, part_id, quantity_stock) values (6, 36, 97);
insert into BranchStock (branch_id, part_id, quantity_stock) values (7, 37, 78);
insert into BranchStock (branch_id, part_id, quantity_stock) values (8, 38, 71);
insert into BranchStock (branch_id, part_id, quantity_stock) values (9, 39, 82);
insert into BranchStock (branch_id, part_id, quantity_stock) values (10, 40, 38);
insert into BranchStock (branch_id, part_id, quantity_stock) values (11, 41, 62);
insert into BranchStock (branch_id, part_id, quantity_stock) values (12, 42, 63);
insert into BranchStock (branch_id, part_id, quantity_stock) values (13, 43, 38);
insert into BranchStock (branch_id, part_id, quantity_stock) values (14, 44, 80);
insert into BranchStock (branch_id, part_id, quantity_stock) values (15, 45, 68);
insert into BranchStock (branch_id, part_id, quantity_stock) values (1, 46, 9);
insert into BranchStock (branch_id, part_id, quantity_stock) values (2, 47, 53);
insert into BranchStock (branch_id, part_id, quantity_stock) values (3, 48, 56);
insert into BranchStock (branch_id, part_id, quantity_stock) values (4, 49, 67);
insert into BranchStock (branch_id, part_id, quantity_stock) values (5, 50, 99);
insert into BranchStock (branch_id, part_id, quantity_stock) values (6, 51, 88);
insert into BranchStock (branch_id, part_id, quantity_stock) values (7, 1, 73);
insert into BranchStock (branch_id, part_id, quantity_stock) values (8, 2, 86);
insert into BranchStock (branch_id, part_id, quantity_stock) values (9, 3, 85);
insert into BranchStock (branch_id, part_id, quantity_stock) values (10, 4, 97);
insert into BranchStock (branch_id, part_id, quantity_stock) values (11, 5, 57);
insert into BranchStock (branch_id, part_id, quantity_stock) values (12, 6, 92);
insert into BranchStock (branch_id, part_id, quantity_stock) values (13, 7, 90);
insert into BranchStock (branch_id, part_id, quantity_stock) values (14, 8, 66);
insert into BranchStock (branch_id, part_id, quantity_stock) values (15, 9, 48);
insert into BranchStock (branch_id, part_id, quantity_stock) values (1, 10, 84);
insert into BranchStock (branch_id, part_id, quantity_stock) values (2, 11, 31);
insert into BranchStock (branch_id, part_id, quantity_stock) values (3, 12, 48);
insert into BranchStock (branch_id, part_id, quantity_stock) values (4, 13, 76);
insert into BranchStock (branch_id, part_id, quantity_stock) values (5, 14, 33);
insert into BranchStock (branch_id, part_id, quantity_stock) values (6, 15, 18);
insert into BranchStock (branch_id, part_id, quantity_stock) values (7, 16, 74);
insert into BranchStock (branch_id, part_id, quantity_stock) values (8, 17, 30);
insert into BranchStock (branch_id, part_id, quantity_stock) values (9, 18, 10);
insert into BranchStock (branch_id, part_id, quantity_stock) values (10, 19, 73);
insert into BranchStock (branch_id, part_id, quantity_stock) values (11, 20, 30);
insert into BranchStock (branch_id, part_id, quantity_stock) values (12, 21, 8);
insert into BranchStock (branch_id, part_id, quantity_stock) values (13, 22, 63);
insert into BranchStock (branch_id, part_id, quantity_stock) values (14, 23, 73);
insert into BranchStock (branch_id, part_id, quantity_stock) values (15, 24, 30);
insert into BranchStock (branch_id, part_id, quantity_stock) values (1, 25, 45);
insert into BranchStock (branch_id, part_id, quantity_stock) values (2, 26, 21);
insert into BranchStock (branch_id, part_id, quantity_stock) values (3, 27, 64);
insert into BranchStock (branch_id, part_id, quantity_stock) values (4, 28, 10);
insert into BranchStock (branch_id, part_id, quantity_stock) values (5, 29, 85);
insert into BranchStock (branch_id, part_id, quantity_stock) values (6, 30, 76);
insert into BranchStock (branch_id, part_id, quantity_stock) values (7, 31, 53);
insert into BranchStock (branch_id, part_id, quantity_stock) values (8, 32, 76);
insert into BranchStock (branch_id, part_id, quantity_stock) values (9, 33, 7);
insert into BranchStock (branch_id, part_id, quantity_stock) values (10, 34, 40);
insert into BranchStock (branch_id, part_id, quantity_stock) values (11, 35, 63);
insert into BranchStock (branch_id, part_id, quantity_stock) values (12, 36, 14);
insert into BranchStock (branch_id, part_id, quantity_stock) values (13, 37, 57);
insert into BranchStock (branch_id, part_id, quantity_stock) values (14, 38, 88);
insert into BranchStock (branch_id, part_id, quantity_stock) values (15, 39, 57);
insert into BranchStock (branch_id, part_id, quantity_stock) values (1, 40, 15);
insert into BranchStock (branch_id, part_id, quantity_stock) values (2, 41, 17);
insert into BranchStock (branch_id, part_id, quantity_stock) values (3, 42, 91);
insert into BranchStock (branch_id, part_id, quantity_stock) values (4, 43, 6);
insert into BranchStock (branch_id, part_id, quantity_stock) values (5, 44, 33);
insert into BranchStock (branch_id, part_id, quantity_stock) values (6, 45, 70);
insert into BranchStock (branch_id, part_id, quantity_stock) values (7, 46, 81);
insert into BranchStock (branch_id, part_id, quantity_stock) values (8, 47, 79);
insert into BranchStock (branch_id, part_id, quantity_stock) values (9, 48, 69);
insert into BranchStock (branch_id, part_id, quantity_stock) values (10, 49, 84);

insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (1, 1, 2, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (2, 2, 5, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (3, 3, 9, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (4, 4, 1, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (5, 5, 1, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (6, 6, 1, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (7, 7, null, 3);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (8, 8, 4, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (9, 9, 1, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (10, 10, 1, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (11, 11, null, 1);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (12, 12, null, 4);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (13, 13, 10, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (14, 14, 1, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (15, 15, null, 2);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (16, 16, null, 1);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (17, 17, 5, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (18, 18, 4, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (19, 19, 8, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (20, 20, 7, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (21, 21, 8, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (22, 22, 2, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (23, 23, 1, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (24, 24, 8, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (25, 25, 8, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (26, 26, 6, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (27, 27, null, 4);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (28, 28, 4, null);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (29, 29, null, 1);
insert into BookingItem (booking_item_id, booking_id, service_id, package_id) values (30, 30, 7, null);

INSERT INTO StaffRole (staff_id, role_id) 
SELECT staff_id, (SELECT role_id FROM Role WHERE role_name = 'Manager')
FROM Staff 
WHERE staff_id BETWEEN 31 AND 42;

UPDATE Branch SET manager_staff_id = 1 WHERE branch_id = 1;
UPDATE Branch SET manager_staff_id = 32 WHERE branch_id = 2;
UPDATE Branch SET manager_staff_id = 33 WHERE branch_id = 3;
UPDATE Branch SET manager_staff_id = 34 WHERE branch_id = 4;
UPDATE Branch SET manager_staff_id = 35 WHERE branch_id = 5;
UPDATE Branch SET manager_staff_id = 36 WHERE branch_id = 6;
UPDATE Branch SET manager_staff_id = 22 WHERE branch_id = 7;
UPDATE Branch SET manager_staff_id = 23 WHERE branch_id = 8;
UPDATE Branch SET manager_staff_id = 37 WHERE branch_id = 9;
UPDATE Branch SET manager_staff_id = 38 WHERE branch_id = 10;
UPDATE Branch SET manager_staff_id = 39 WHERE branch_id = 11;
UPDATE Branch SET manager_staff_id = 27 WHERE branch_id = 12;
UPDATE Branch SET manager_staff_id = 40 WHERE branch_id = 13;
UPDATE Branch SET manager_staff_id = 41 WHERE branch_id = 14;
UPDATE Branch SET manager_staff_id = 42 WHERE branch_id = 15;



create index idx_booking_customer_id on booking(customer_id);
create index idx_booking_vehicle_id on booking(vehicle_id);
create index idx_booking_branch_id on booking(branch_id);
create index idx_vehicle_customer_id on vehicle(customer_id);
create index idx_invoice_booking_id on invoice(booking_id);
create index idx_payment_invoice_id on payment(invoice_id);
create index idx_staff_branch_id on staff(branch_id);
create index idx_task_booking_id on task(booking_id);
create index idx_task_staff_id on task(staff_id);
CREATE INDEX idx_task_service_id ON Task(service_id);
create index idx_usage_task_id on usage(task_id);
create index idx_usage_part_id on Usage(part_id);
create index idx_customer_lname on Customer(customer_lname);
create index idx_staff_lname on Staff(staff_lname);
create index idx_booking_date on Booking(booking_date);
create index idx_invoice_issue_date on Invoice(issue_date);
create index idx_shift_date on Shift(shift_date);
create index idx_invoice_status on Invoice(invoice_status);
create index idx_task_status on Task(task_status);
create index idx_bay_status on Bay(bay_status);
create index idx_staffskill_skill_id on StaffSkill(skill_id);
create index idx_staffskill_staff_id on StaffSkill(staff_id);
create index idx_staffrole_role_id on StaffRole(role_id);
create index idx_staffrole_staff_id on StaffRole(staff_id);
create index idx_bay_branch_id on Bay(branch_id);
create index idx_psl_package_id on PackageServiceLink(package_id);
create index idx_psl_service_id on PackageServiceLink(service_id);
create index idx_customer_membership_id on Customer(membership_id);
create index idx_shift_staff_id on Shift(staff_id);
create index idx_shift_branch_id on Shift(branch_id);
create index idx_emergencycontact_customer_id on EmergencyContact(customer_id);
create index idx_vehicleallocation_vehicle_id on VehicleAllocation(vehicle_id);
create index idx_vehicleallocation_booking_id on VehicleAllocation(booking_id);
create index idx_vehicleallocation_bay_id on VehicleAllocation(bay_id);
create index idx_vehicleallocation_staff_id on VehicleAllocation(staff_id);
create index idx_communicationlog_booking_id on CommunicationLog(booking_id);
create index idx_communicationlog_customer_id on CommunicationLog(customer_id);
create index idx_feedback_booking_id on Feedback(booking_id);
create index idx_feedback_resolved_by_staff on Feedback(resolved_by_staff);
create index idx_compliance_staff_id on ComplianceRecord(compliance_staff);
create index idx_compliance_bay_id on ComplianceRecord(compliance_bay);
create index idx_compliance_vehicle_id on ComplianceRecord(vehicle_id);
create index idx_branch_manager_staff_id on Branch(manager_staff_id);
create index idx_branchstock_branch_id on BranchStock(branch_id);
create index idx_branchstock_part_id on BranchStock(part_id);
create index idx_bookingitem_booking_id on BookingItem(booking_id);
create index idx_bookingitem_service_id on BookingItem(service_id);
create index idx_bookingitem_package_id on BookingItem(package_id);
create index idx_booking_status on Booking(booking_status);
create index idx_booking_date on Booking(booking_date);
create index idx_invoice_due_date on Invoice(due_date);

create role manager with login password 'password123';
grant all privileges on all tables in schema public to manager;
grant all privileges on all sequences in schema public to manager;

create role receptionist with login password 'password123';
grant select, insert, update, delete on
customer, booking, invoice, payment, emergencycontact, CommunicationLog, feedback, vehicle
to receptionist;
grant select on
service, servicepackage, PackageServiceLink, staff, shift, branch, bay, part, VehicleAllocation
to receptionist;
grant usage, select on sequence
customer_customer_id_seq, booking_booking_id_seq, invoice_invoice_id_seq, 
payment_payment_id_seq, emergencycontact_contact_id_seq, communicationlog_log_id_seq,
feedback_feedback_id_seq, vehicle_vehicle_id_seq
to receptionist;

create role technician with login password 'password123';
grant select, insert, update on
task, usage, compliancerecord, VehicleAllocation
to technician;
grant select on
vehicle, part, service, bay, branch, skill
to technician;
grant usage, select on sequence
task_task_id_seq, usage_usage_id_seq, VehicleAllocation_allocation_id_seq
to technician;

create role apprentice with login password 'password123';
grant select on 
vehicle, part, service, bay, branch, skill, task, usage, VehicleAllocation
to apprentice;
grant insert, update on task, usage to apprentice;
grant usage, select on sequence task_task_id_seq, usage_usage_id_seq to apprentice;



