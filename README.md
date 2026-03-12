# khonager F-Droid Repository

This repository hosts a custom F-Droid-compatible app repository for `khonager` apps.

## What users do

1. Install an F-Droid-compatible client (F-Droid, Neo Store, Droid-ify).
2. Add this repository URL:
   - `https://khonager.github.io/f-droid/repo`
3. Verify the repository fingerprint shown in this repo.
4. Install/update apps from this repository.

## Repository layout

- `repo/`: Published APKs and generated F-Droid index files.
- `metadata/`: App metadata (`<applicationId>.yml`).
- `scripts/`: Local and CI helper scripts.
- `.github/workflows/publish.yml`: CI workflow to generate and publish repo index.

## Initial setup (one-time)

1. Enable GitHub Pages for this repository:
   - Settings -> Pages
   - Source: `GitHub Actions`
2. Create a repository signing keystore (for F-Droid index signing):
   - Run `scripts/init_keystore.sh` locally OR provide one you already use.
3. Add these GitHub secrets:
   - `FDROID_KEYSTORE_BASE64`
   - `FDROID_KEYSTORE_PASSWORD`
   - `FDROID_KEY_ALIAS`
   - `FDROID_KEY_PASSWORD`
4. Set GitHub variable:
   - `FDROID_REPO_URL` = `https://khonager.github.io/f-droid/repo`

## Automatic Trans stable sync

The publish workflow automatically downloads the latest stable Android APK from:
- `khonager/Trans` latest GitHub release
- asset name: `trans.apk`

Then it rebuilds the F-Droid index and publishes to GitHub Pages.

## Local publish (optional)

You can also run locally:

```bash
FDROID_REPO_URL=https://khonager.github.io/f-droid/repo \
FDROID_KEYSTORE_PASSWORD=... \
FDROID_KEY_ALIAS=... \
FDROID_KEY_PASSWORD=... \
FDROID_KEYSTORE_PATH=./fdroid-repo.jks \
./scripts/publish_local.sh
```

## Notes

- Keep repo signing key stable long-term; changing it forces users to re-trust the repo.
- APK signing key and F-Droid repo signing key are different concepts; both should be backed up.
