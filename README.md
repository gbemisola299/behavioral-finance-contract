# Behavioral Finance Token (BFT)

A Clarity smart contract implementing a behavioral economics-driven token system that incentivizes users to achieve their financial goals through rewards and penalties.

## Overview

The Behavioral Finance Token (BFT) is a fungible token implementation on the Stacks blockchain that combines traditional token functionality with behavioral economics principles. It helps users set, track, and achieve financial goals by providing token rewards for successful completion and implementing penalties for missed targets.

## Features

### SIP-010 Compliance
- Fully implements the SIP-010 fungible token standard
- Supports token transfers with optional memos
- Complete metadata implementation

### Goal Management
- Set personalized financial goals with deadlines
- Track progress towards goals
- Multiple simultaneous goals per user
- Flexible goal types and amounts

### Reward System
- Automatic token rewards for achieving goals
- Configurable reward rates
- Secure minting mechanism
- Progress-based distribution

### Penalty Mechanism
- Automated penalty application for missed deadlines
- Configurable penalty rates
- Secure penalty collection
- Fair deadline management

## Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- [Stacks CLI](https://github.com/blockstack/stacks.js) (optional for mainnet deployment)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/behavioral-finance-token.git
cd behavioral-finance-token
```

2. Install dependencies:
```bash
clarinet install
```

## Usage

### Local Development

1. Start Clarinet console:
```bash
clarinet console
```

2. Set a financial goal:
```clarity
(contract-call? .behavioral-finance-token set-goal "emergency_fund" u1000 u100)
```

3. Update progress:
```clarity
(contract-call? .behavioral-finance-token update-progress u0 u500)
```

### Testing

Run the test suite:
```bash
clarinet test
```

## Contract Functions

### Core Token Functions

- `transfer`: Transfer tokens between principals
- `get-name`: Get token name
- `get-symbol`: Get token symbol
- `get-decimals`: Get token decimals
- `get-balance`: Get principal's token balance
- `get-total-supply`: Get total token supply

### Goal Management Functions

- `set-goal`: Create a new financial goal
- `update-progress`: Update progress towards a goal
- `apply-penalty`: Apply penalty for missed deadline

## Error Codes

- `u1`: Unauthorized transfer
- `u2`: Invalid amount
- `u3`: Invalid transfer to self
- `u399`: Empty goal type
- `u400`: Invalid goal parameters
- `u401`: Invalid deadline
- `u402`: Deadline passed
- `u403`: Goal already achieved
- `u404`: Goal not found

## Security

The contract implements several security measures:
- Input validation for all public functions
- Goal ownership verification
- Progress bounds checking
- Secure reward distribution
- Protected penalty application

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Contact

- Maintainer: [Gbemisola Oginni]
- Email: [gbemisola299@gmail.com]

## Acknowledgments

- Stacks Foundation for the SIP-010 standard
- Hiro Systems for Clarinet
- [Other acknowledgments]