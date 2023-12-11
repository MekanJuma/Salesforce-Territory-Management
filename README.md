# Salesforce Territory Management: Comprehensive Guide
<img src="https://images.ctfassets.net/k0lk9kiuza3o/36tqiPIJ0QUpG62GCmG4Cr/f1ac2b51d983a22aed5a1b4f5a8a114e/Calendly_TerritoryManagementSalesforce_Blog_OG_1920x1080.png?w=1920&h=1080&q=85&fm=webp" width="100%" >

## Overview
Salesforce Territory Management is a dynamic tool designed for organizations with complex sales structures, enabling them to efficiently manage and segment their sales data and teams across various dimensions such as geography, product lines, or customer size.

## Key Components and Settings
**Territory Settings**
- **Enablement**: A permanent feature once enabled.
- **Default Account Access**: Sets the default access level for users in a territory to accounts in that territory, typically Read Only or Read/Write.
- **Opportunity and Case Access**: Similar to accounts, this sets default access levels for opportunities and cases in a territory.

**Territory Objects**
- **Territory2**: Represents an individual territory.
- **Territory2Model**: The overall territory structure or model.
- **Territory2Type**: Classifies types of territories.
- **UserTerritory2Association**: Links users to territories.
- **ObjectTerritory2Association**: Associates Salesforce objects (like accounts) with territories.

**Territory Model**
- **Multiple Models**: You can create multiple models, but only one can be active at any given time.
- **Activation**: Territories in a model do not share accounts until the model is activated.
- **Versioning**: Treat each model as a version for evolving sales strategies and historical analysis.

**Territory Type**
- Classifies territories into distinct categories for more structured management and reporting.

**Territory Type Priority**
- Establishes the hierarchy of importance among different territory types, crucial in overlapping territories scenarios.

**Territory Hierarchy**
- Defines the organizational structure within the sales teams, showing the relationships between different territories.

**Assignment Rules**
- Automates the process of assigning accounts to territories based on specific criteria.

## Role Hierarchy vs Territory Hierarchy
**Role Hierarchy**
- A user has a one role.
- An account is owned by a single user.
- User has a single forecast based on role
- An account is accessible by the owner and users above in the role hierarchy.
- Role hierarchy affects sharing settings for all standard and custom objects in Salesforce.

**Territory Hierarchy**
- A user can be part of multiple territories.
- An account can be belonged to multiple territories.
- Users have a forecast for each territory in which they work with active Opportunities
- An account is accessible by all users in the territories to which it is assigned, as well as those above them in the territory hierarchy.
- Territory Management only affects the sharing settings of accounts and the standard objects that have a master-detail relationship to accounts.

## Sharing Based on Territory
- **Sharing Capabilities**: With Territory Management, Salesforce introduces the ability to share records based on territory assignments.
- **Granular Access Control**: Allows for more nuanced and market-focused sharing rules, going beyond the internal organizational structure.
- **Dynamic Sharing Adjustments**: As accounts and opportunities are reassigned to different territories, sharing settings adjust automatically to reflect these changes.


## **Author:** Mekan Jumayev
