# Step-by-Step Secrets Management Migration

## Current Issue
The infinite recursion error occurs because of circular dependencies in the module system. Let's fix this incrementally.

## Step 1: Fix Current Configuration (Immediate Fix)

The current `users/daseeds/default.nix` has been updated with the correct fail2ban syntax. This should resolve the immediate build error.

## Step 2: Test Current Configuration

```bash
# Test the current configuration
sudo nixos-rebuild test --flake .#eurydice
```

If this works, proceed to Step 3. If not, check for other syntax errors.

## Step 3: Incremental SOPS Improvements

### 3a. Update User SOPS Configuration

Replace the content of `users/daseeds/sops.nix` with the minimal version:

```nix
{ inputs, ... }:
let
  secretspath = builtins.toString inputs.secrets;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "/home/daseeds/.config/sops/age/keys.txt";
    defaultSopsFile = "${secretspath}/secrets.yaml";
    validateSopsFiles = false;

    secrets = {
      "private_keys/daseeds" = {
        path = "~/.ssh/daseeds";
      };
    };
  };
}
```

### 3b. Test User SOPS Changes

```bash
sudo nixos-rebuild test --flake .#eurydice
```

## Step 4: Add Password Management (Optional)

Only after Step 3 works, uncomment and modify the password line in `users/daseeds/default.nix`:

```nix
# Change this line:
#        hashedPasswordFile = config.age.secrets.hashedUserPassword.path;

# To this:
        hashedPasswordFile = config.sops.secrets."users/daseeds/password".path;
```

And add the password secret to your SOPS configuration:

```nix
secrets = {
  "private_keys/daseeds" = {
    path = "~/.ssh/daseeds";
  };
  "users/daseeds/password" = {
    neededForUsers = true;
  };
};
```

## Step 5: Remove agenix (After Everything Works)

Only after confirming SOPS works completely:

1. Remove agenix from `flake.nix` inputs
2. Remove agenix imports from the configuration
3. Remove `users/daseeds/age.nix`

## Troubleshooting

### If you get infinite recursion:
- Revert to the last working configuration
- Check for circular imports
- Ensure you're not importing both old and new configurations simultaneously

### If SOPS secrets don't work:
- Verify your age key exists: `ls -la ~/.config/sops/age/keys.txt`
- Check your secrets repository has the correct structure
- Ensure the public key is added to `.sops.yaml` in your secrets repo

### If fail2ban doesn't start:
- Check logs: `journalctl -u fail2ban`
- Verify the jail configuration syntax

## Current Working State

Your system should now build successfully with:
- Fixed fail2ban configuration
- Current SOPS setup maintained
- No infinite recursion

## Next Steps (When Ready)

1. Generate age keys if not already done
2. Update secrets repository structure
3. Test minimal SOPS changes
4. Gradually add more secrets
5. Remove deprecated configurations

This incremental approach ensures you always have a working system while improving security.