# Testing gates

## Per PR
- `stylua --check src`
- `selene src`
- `rojo build default.project.json -o build/prototype.rbxlx`
- Small, relevant Luau logic tests when test runner is introduced.
- Report any NOT RUN command due to missing tools; never claim a passing test without execution.

## Before public beta
- Studio playtest with 2+ players (not only solo).
- Inventory/currency authority: invalid client requests produce no reward.
- Claim/steal checks: unauthorized plot, duplicate request, rapid spam.
- Mobile screen size, touch controls, UI readability.
- Respawn/rejoin, data save/load failure simulation, clean fallback.
- Track script errors and frame-rate/memory behavior on a lower-end mobile device.

## Safe content checks
- All shipped art/scripts have appropriate rights.
- Toolbox and external models are scanned for executable scripts.
- Studio scene backed up before AI-driven changes.
- Rollback procedure verified before the first live publish.
