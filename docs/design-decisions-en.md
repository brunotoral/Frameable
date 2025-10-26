
# Design Decisions

## Why We Use Service Objects

We use Service Objects to extract business logic from Controllers and Models, placing it into a dedicated layer. This architectural decision ensures **cleaner, more organized code** that is easier to understand, maintain, and test.

## Math Calculations on the Database

We execute complex mathematical calculations—such as geometric comparisons, collision detection, and area filtering—directly within the database using **SQL**.

This approach leverages the native power of the database engine (like PostgreSQL) to perform calculations on large datasets in a highly **parallelized and optimized** manner. By offloading these resource-intensive processes from the application server, we achieve **faster query performance** and ensure more efficient use of application memory and CPU resources.

## Pagination on Index Actions

We implement pagination across all `index` actions to effectively manage the volume of data retrieved.

By limiting the number of records fetched from the database in a single request, we prevent excessive data transfer, ensure **predictably fast response times**, and keep resource consumption manageable for both the application and the database server, leading to a smoother user experience.

## View Caching

View caching is utilized to save the rendered output ( JSON) of complex views or partials into a fast-access layer (like application memory or a dedicated key-value store).

This mechanism allows the server to completely **skip the rendering pipeline** and avoid repetitive database queries for static or frequently accessed data. The direct result is a significant **improvement in request response time** and a reduction in application latency.

## Preloading Associations (Eager Loading)

We use _eager loading_ techniques (`includes` or `preload`) when retrieving models and their associations.

The primary goal is to drastically **reduce the total number of database queries**. By fetching associated data in a few optimized queries, we eliminate the infamous **N+1 query problem**, where one initial query is followed by _N_ additional queries for the associated records. This optimization is crucial for performance at scale.

