# Copyright 2018 Onestein
# License AGPL-3.0 or later (http://www.gnu.org/licenses/agpl).

from odoo import fields
from odoo.tests.common import TransactionCase


class TestProjectTimeline(TransactionCase):
    def test_date_end_doesnt_unset(self):
        stage_id = self.ref("project.project_stage_2")
        project_id = self.ref("project.project_project_1")
        task = self.env["project.task"].create(
            {
                "name": "1",
                "date_assign": "2018-05-01 00:00:00",
                "date_end": "2018-05-07 00:00:00",
                "project_id": project_id,
            }
        )
        task.write({"stage_id": stage_id, "date_end": "2018-10-07 00:00:00"})
        self.assertEqual(
            task.date_end, fields.Datetime.from_string("2018-10-07 00:00:00")
        )
