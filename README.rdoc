This attempted to be a demo of the GitHub [email incident](https://github.com/blog/1440-today-s-email-incident)
Rails 3.2.13 scoping behavior issue, but I couldn't reproduce it. Here's the repository anyway. Just pull down,
bundle, migrate, and try what's in that blog post. Here's what I got:

~/test_github_thing » bundle exec rake db:migrate

        ==  CreateOrganizations: migrating ============================================
        -- create_table(:organizations)
          -> 0.0086s
        ==  CreateOrganizations: migrated (0.0087s) ===================================
        
        ==  CreateTeams: migrating ====================================================
        -- create_table(:teams)
          -> 0.0016s
        ==  CreateTeams: migrated (0.0016s) ===========================================
        
        ------------------------------------------------------------

~/test_github_thing » rails c

        Loading development environment (Rails 3.2.13)

        1.9.3-p0 :001 > Organization.destroy_all
          Organization Load (0.1ms)  SELECT "organizations".* FROM "organizations"
        => []

        1.9.3-p0 :002 > Team.destroy_all
          Team Load (0.1ms)  SELECT "teams".* FROM "teams"
        => []

        1.9.3-p0 :003 > github = Organization.create(:name => "GitHub", :has_octocats => true)
          (0.1ms)  begin transaction
  SQL (6.0ms)  INSERT INTO "organizations" ("created_at", "has_octocats", "name", "updated_at") VALUES (?, ?, ?, ?)  [["created_at", Wed, 20 Mar 2013 03:26:14 UTC        +00:00], ["has_octocats", true], ["name", "GitHub"], ["updated_at", Wed, 20 Mar 2013 03:26:14 UTC +00:00]]
          (1.0ms)  commit transaction
        => #<Organization id: 1, name: "GitHub", has_octocats: true, created_at: "2013-03-20 03:26:14", updated_at: "2013-03-20 03:26:14">

        1.9.3-p0 :004 > acme   = Organization.create(:name => "Acme",   :has_octocats => false)
          (0.1ms)  begin transaction
  SQL (0.5ms)  INSERT INTO "organizations" ("created_at", "has_octocats", "name", "updated_at") VALUES (?, ?, ?, ?)  [["created_at", Wed, 20 Mar 2013 03:26:19 UTC        +00:00], ["has_octocats", false], ["name", "Acme"], ["updated_at", Wed, 20 Mar 2013 03:26:19 UTC +00:00]]
          (2.3ms)  commit transaction
        => #<Organization id: 2, name: "Acme", has_octocats: false, created_at: "2013-03-20 03:26:19", updated_at: "2013-03-20 03:26:19">

        1.9.3-p0 :005 > github.teams.create(:name => "Supportocats")
          (0.1ms)  begin transaction
  SQL (0.8ms)  INSERT INTO "teams" ("created_at", "name", "organization_id", "updated_at") VALUES (?, ?, ?, ?)  [["created_at", Wed, 20 Mar 2013 03:26:24 UTC         +00:00], ["name", "Supportocats"], ["organization_id", 1], ["updated_at", Wed, 20 Mar 2013 03:26:24 UTC +00:00]]
          (0.8ms)  commit transaction
        => #<Team id: 1, name: "Supportocats", organization_id: 1, created_at: "2013-03-20 03:26:24", updated_at: "2013-03-20 03:26:24">

        1.9.3-p0 :006 > acme.teams.create(:name => "Roadrunners")
          (0.1ms)  begin transaction
  SQL (0.5ms)  INSERT INTO "teams" ("created_at", "name", "organization_id", "updated_at") VALUES (?, ?, ?, ?)  [["created_at", Wed, 20 Mar 2013 03:26:28 UTC         +00:00], ["name", "Roadrunners"], ["organization_id", 2], ["updated_at", Wed, 20 Mar 2013 03:26:28 UTC +00:00]]
          (2.4ms)  commit transaction
        => #<Team id: 2, name: "Roadrunners", organization_id: 2, created_at: "2013-03-20 03:26:28", updated_at: "2013-03-20 03:26:28">

        1.9.3-p0 :007 > github.id
        => 1

        1.9.3-p0 :008 > acme.id
        => 2

        1.9.3-p0 :009 > teams = github.teams
          Team Load (0.2ms)  SELECT "teams".* FROM "teams" WHERE "teams"."organization_id" = 1
        => [#<Team id: 1, name: "Supportocats", organization_id: 1, created_at: "2013-03-20 03:26:24", updated_at: "2013-03-20 03:26:24">]

        1.9.3-p0 :010 > teams.length
        => 1

        1.9.3-p0 :011 > teams.first.name
        => "Supportocats"

        1.9.3-p0 :012 > teams = github.teams.using_octocats_class_method
  Team Load (0.3ms)  SELECT "teams".* FROM "teams" WHERE "teams"."organization_id" = 1 AND "teams"."organization_id" IN (SELECT id FROM "organizations" WHERE         "organizations"."has_octocats" = 't')
        => [#<Team id: 1, name: "Supportocats", organization_id: 1, created_at: "2013-03-20 03:26:24", updated_at: "2013-03-20 03:26:24">]

        1.9.3-p0 :013 > teams = acme.teams.using_octocats_class_method
  Team Load (0.3ms)  SELECT "teams".* FROM "teams" WHERE "teams"."organization_id" = 2 AND "teams"."organization_id" IN (SELECT id FROM "organizations" WHERE         "organizations"."has_octocats" = 't')
        => []

        1.9.3-p0 :014 > teams.length
        => 0

        1.9.3-p0 :015 > teams = acme.teams.using_octocats_scope
  Team Load (0.3ms)  SELECT "teams".* FROM "teams" WHERE "teams"."organization_id" = 2 AND "teams"."organization_id" IN (SELECT id FROM "organizations" WHERE         "organizations"."has_octocats" = 't')
        => []
