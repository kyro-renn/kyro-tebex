# Kyro Tebex Integration

![Claim](https://github.com/user-attachments/assets/8a60a6e6-7834-400b-b739-1119ca7d713f)

## Tebex Commands

### Credits with Membership
```lua
purchase_package_tebex {"transid":"{transaction}", "packagename":"gold", "credits":"10000"}
```

### Just Credits
```lua
purchase_package_tebex {"transid":"{transaction}", "packagename":"", "credits":"10000"}
```

### Just Membership
```lua
purchase_package_tebex {"transid":"{transaction}", "packagename":"gold", "credits":""}
```

---

## Available Exports

### Get Player Balance
**Export:**
```lua
exports['kyro_tebex']:GetBalance(license)
```
**Returns:** The player's current credit balance.

**Example Usage:**
```lua
local balance = exports['kyro_tebex']:GetBalance(playerLicense)
print("Player has", balance, "credits")
```

---

### Get Player Memberships
**Export:**
```lua
exports['kyro_tebex']:GetMembership(license)
```
**Returns:** A table containing the player's active memberships.

**Example Usage:**
```lua
local memberships = exports['kyro_tebex']:GetMembership(playerLicense)
for _, membership in ipairs(memberships) do
    print("Membership:", membership.member, "Expires on:", membership.expire_date)
end
```

---

### Remove Credits from a Player
**Export:**
```lua
exports['kyro_tebex']:RemoveCredits(license, amount)
```
**Returns:**
- `true` if successful.
- `false` if the player does not have enough credits.

**Example Usage:**
```lua
local success = exports['kyro_tebex']:RemoveCredits(playerLicense, 50)
if success then
    print("Removed 50 credits from player.")
else
    print("Not enough credits.")
end
```

---

### Add Credits to a Player
**Export:**
```lua
exports['kyro_tebex']:AddCredits(license, amount)
```
**Returns:** `true` if successful.

**Example Usage:**
```lua
exports['kyro_tebex']:AddCredits(playerLicense, 100)
print("Added 100 credits to player.")
```

---

## Conclusion
This guide provides an overview of the commands and exports available in the Kyro Tebex integration. These allow for checking balances, redeeming codes, managing credits, and handling memberships efficiently.

