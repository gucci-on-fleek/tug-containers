[(
    # Split the input by lines
    split("\n")[:-1][]

    # Split the fields on colons; [$username, $pw, $email, $extra_id].
    | split(":")

    # Convert the fields into an object.
    | {
        username: .[0],
        password: .[1],
        email: .[2],
        id: ((.[3] // (.[0] | scan("\\d+$"))) | try tonumber catch -1),
        nameonly: (.[0] | scan("^\\D+")),
    }

    # Filter out the deactivated accounts.
    | select(.username | startswith("deact") | not)

    # bcrypt is the best hash format supported by both Authelia and Apache:
    #
    #     https://www.authelia.com/reference/guides/passwords/#identification
    #     https://httpd.apache.org/docs/current/programs/htpasswd.html
    | select(.password | startswith("$2y$"))

    # Ok, now let's convert into the Authelia user database format.
    | {
        (.username): {
            password: (.password | sub("^\\$2y\\$"; "$2b$")),
            displayname: .nameonly,
            email: .email,
            extra: {
                id: .id
            },
            groups: [
                "member",
                (if .username | test("^(mchernoff10112|karl)$") then
                    "admin"
                else
                    empty
                end)
            ],
        },
    }
)]

# Flatten the array into a single object.
| add

# Set the top-level key to "users".
| { users: . }
