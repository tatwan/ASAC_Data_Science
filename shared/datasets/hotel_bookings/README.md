# Hotel bookings (Assignment 2)

Bookings for two hotels in Portugal, a resort hotel in the Algarve (H1) and a city hotel in Lisbon (H2), due to arrive
between 1 July 2015 and 31 August 2017. One row is one booking, including bookings that were cancelled. 119,390 rows,
33 columns.

| | |
|---|---|
| Source | Nuno Antonio, Ana de Almeida and Luís Nunes, "Hotel booking demand datasets", *Data in Brief* 22 (2019) 41–49, [doi:10.1016/j.dib.2018.11.126](https://doi.org/10.1016/j.dib.2018.11.126) |
| Copy used | [TidyTuesday, 11 February 2020](https://github.com/rfordatascience/tidytuesday/tree/main/data/2020/2020-02-11) (`hotels.csv`) |
| Licence | CC BY 4.0 (the article: "This is an open access article under the CC BY license") |
| Course copy | `hotel_bookings.csv`, taken 29 October 2026 |
| Used in | Assignment 2 ([`modules/03-machine-learning-and-ai/assignments/A02-ML-Hotel-Bookings/`](../../../modules/03-machine-learning-and-ai/assignments/A02-ML-Hotel-Bookings/README.md)) |

**Changes in the course copy:** a `booking_id` column (1 to 119,390, in the order of the source file) so the fixed
groups never move; the text `NULL` in `agent`, `company` and `country` and `NA` in `children` turned into empty cells,
so BigQuery's Auto detect reads `children`, `agent` and `company` as numbers and the gaps as `NULL`. Nothing else
changed: 488 bookings have no country, 4 have no `children` value.

The authors removed everything that identifies the hotels or the guests; room types, agents and companies are codes.
Their data is as of the day before each booking's arrival, so some columns record what happened after the booking was
made (Assignment 2 asks learners to find them).

## Columns

| Column | Type | Description |
|---|---|---|
| `booking_id` | INTEGER | Course-added row number |
| `hotel` | STRING | `Resort Hotel` or `City Hotel` |
| `is_canceled` | INTEGER | 1 if the booking was cancelled or the guest did not show, 0 if not |
| `lead_time` | INTEGER | Days between entering the booking and the arrival date |
| `arrival_date_year`, `arrival_date_month`, `arrival_date_week_number`, `arrival_date_day_of_month` | INTEGER, STRING, INTEGER, INTEGER | Arrival date |
| `stays_in_weekend_nights`, `stays_in_week_nights` | INTEGER | Nights booked or stayed, Saturday–Sunday and Monday–Friday |
| `adults`, `children`, `babies` | INTEGER | Guests |
| `meal` | STRING | `BB` bed and breakfast, `HB` half board, `FB` full board, `SC` or `Undefined` no meal package |
| `country` | STRING | Country of origin, ISO 3166 three-letter code |
| `market_segment`, `distribution_channel` | STRING | Who sold the booking (`TA` travel agents, `TO` tour operators) |
| `is_repeated_guest` | INTEGER | 1 if the booking name had booked before |
| `previous_cancellations`, `previous_bookings_not_canceled` | INTEGER | The customer's earlier bookings |
| `reserved_room_type`, `assigned_room_type` | STRING | Room type booked, and the one finally assigned (codes) |
| `booking_changes` | INTEGER | Changes made between booking and check-in or cancellation |
| `deposit_type` | STRING | `No Deposit`; `Non Refund` (the whole stay, not refundable); `Refundable` (part of the stay) |
| `agent`, `company` | INTEGER | IDs of the travel agency and the company that booked, if any |
| `days_in_waiting_list` | INTEGER | Days on the waiting list before the booking was confirmed |
| `customer_type` | STRING | `Transient`, `Transient-Party`, `Contract`, `Group` |
| `adr` | FLOAT | Average daily rate in euros: lodging revenue divided by nights |
| `required_car_parking_spaces` | INTEGER | Parking spaces asked for |
| `total_of_special_requests` | INTEGER | Special requests (twin bed, high floor …) |
| `reservation_status` | STRING | `Check-Out`, `Canceled` or `No-Show`: the booking's last status |
| `reservation_status_date` | DATE | When the last status was set |
