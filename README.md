# Lista zadań

Lista zadań do pracy: priorytety, terminy, notatki, wyszukiwanie, filtry, pasek postępu i historia zmian. Jeden plik statyczny (`index.html`, Tailwind przez CDN), działa na GitHub Pages. Dane są w Supabase (logowanie e-mail + hasło), w `localStorage` zapamiętywane są tylko filtry i zakładka.

Adres: https://kamilowebski.github.io/todo/

## Pliki

| Plik | Opis |
| --- | --- |
| `index.html` | cała aplikacja (HTML, Tailwind przez CDN, JS) |
| `zadania.sql` | tabele `zadania` i `zadania_historia`, wyzwalacz historii i RLS |
| `manifest.webmanifest` | manifest PWA (nazwa, kolory, ikony) |
| `icons/` | favicon, ikona Apple Touch, ikony 192/512 i maskable |

## Uruchomienie

1. W Supabase: SQL Editor → wklej `zadania.sql` → Run.
2. W `index.html` sprawdź `SUPABASE_URL` i `SUPABASE_ANON_KEY` na górze skryptu (klucz publishable, nie `service_role`).
3. Wrzuć zawartość repozytorium na GitHub Pages (gałąź `main`, katalog główny).
4. Konta zakładasz ręcznie: Authentication → Users → Add user (zaznacz Auto Confirm User). Opcjonalnie wyłącz rejestrację: Authentication → Sign In / Providers → „Allow new users to sign up".

Wymagany jest internet: Tailwind (CDN 3.4.17 z wtyczką forms, `colors.page = #f4f7f9`), biblioteka Supabase (CDN, wersja przypięta) oraz `kamilowebski.github.io/hub/apps.js` (przycisk huba).

## Wspólny wygląd (Rejestr, Todo, Diary)

- tylko jasny motyw, tło `bg-page` (`#f4f7f9`), jeden akcent `blue-600`
- kontener `max-w-7xl mx-auto px-4 py-8 space-y-6`, nagłówek z tytułem po lewej i akcjami po prawej
- te same przyciski: główny (Dodaj, Zapisz), drugorzędny (Wyloguj, Anuluj), niebezpieczny (Usuń), ikony jako inline SVG
- logowanie jako karta `max-w-md` na stronie, okna `max-w-[560px]`, potwierdzenie `max-w-[400px]`
- przycisk huba (kwadraciki) w prawym górnym rogu na każdej stronie, ładowany z `hub/apps.js` do `<div id="hub-apps">`

## Uwagi

- Bezpieczeństwo opiera się na RLS w Supabase (`zadania.sql` je włącza). Klucz „publishable" w kodzie jest bezpieczny tylko przy włączonym RLS.
- Wpisy w historii zostają po usunięciu zadania.
