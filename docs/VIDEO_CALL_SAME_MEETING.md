# Video call: same meeting required

For the patient (app) and doctor (web) to see each other in a call, **both must join the same Cloudflare Realtime meeting**.

## Backend requirement

For a given `appointmentId`:

- **Doctor (web)** gets a token via `POST /appointments/:id/start` → response must include a `dyteToken` that is a **Cloudflare Realtime** auth token for meeting **M**.
- **Patient (app)** gets a token via `POST /appointments/:id/accept` → response must include a `dyteToken` that is a **Cloudflare Realtime** auth token for **the same meeting M**.

If the backend returns tokens for different meetings (e.g. creates a new meeting per request), both sides will join different rooms and will always see “Waiting for others to join…” with no remote participant.

## How to verify

When you start a call:

- **App**: Check logs for `[VideoCall] Token meeting ID: <id>`.
- **Web**: Open DevTools → Console and look for `[Consultation] Token meeting ID: <id>`.

The two IDs must be **identical**. If they differ, fix the backend so both endpoints return a token for the same meeting for that appointment.
