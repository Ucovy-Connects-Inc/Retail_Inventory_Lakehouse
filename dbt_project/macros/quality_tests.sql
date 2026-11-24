{% test non_negative(model, column_name) %}
select
    *
from {{ model }}
where {{ column_name }} is not null
  and {{ column_name }} < 0
{% endtest %}

{% test positive(model, column_name) %}
select
    *
from {{ model }}
where {{ column_name }} is not null
  and {{ column_name }} <= 0
{% endtest %}

{% test unique_combination_of_columns(model, combination_of_columns) %}
select
    {{ combination_of_columns | join(', ') }},
    count(*) as record_count
from {{ model }}
group by {{ combination_of_columns | join(', ') }}
having count(*) > 1
{% endtest %}
