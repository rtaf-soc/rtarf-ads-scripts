CREATE VIEW V_EdrHosts AS
SELECT
    m.machine_name,
    d.department_code,
    d.short_name,
    d.long_name
FROM
    "CsMachineStat" m
LEFT OUTER JOIN
    "Departments" d ON m.department_name = d.department_code;
