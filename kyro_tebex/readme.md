
Tebex Commands 

credits with membership

purchase_package_tebex {"transid":"{transaction}", "packagename":"gold","credits":"10000"}

just credits

purchase_package_tebex {"transid":"{transaction}", "packagename":"","credits":"10000"}

jsut membership

purchase_package_tebex {"transid":"{transaction}", "packagename":"gold","credits":""}



Available Exports

1. Get Player Balance

Export:

exports['kyro_tebex']:GetBalance(license)

Returns:

The player's current credit balance.

Example Usage:

local balance = exports['kyro_tebex']:GetBalance(playerLicense)
print("Player has", balance, "credits")

2. Get Player Memberships

Export:

exports['kyro_tebex']:GetMembership(license)

Returns:

A table containing the player's active memberships.

Example Usage:

local memberships = exports['kyro_tebex']:GetMembership(playerLicense)
for _, membership in ipairs(memberships) do
    print("Membership:", membership.member, "Expires on:", membership.expire_date)
end

3. Remove Credits from a Player

Export:

exports['kyro_tebex']:RemoveCredits(license, amount)

Returns:

true if successful.

false if the player does not have enough credits.

Example Usage:

local success = exports['kyro_tebex']:RemoveCredits(playerLicense, 50)
if success then
    print("Removed 50 credits from player.")
else
    print("Not enough credits.")
end

4. Add Credits to a Player

Export:

exports['kyro_tebex']:AddCredits(license, amount)

Returns:

true if successful.

Example Usage:

exports['kyro_tebex']:AddCredits(playerLicense, 100)
print("Added 100 credits to player.")





Conclusion

This guide provides an overview of the commands and exports available in the Kyro Tebex integration. These allow for checking balances, redeeming codes, managing credits, and handling memberships efficiently.

