#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Tests for `log_aggregator_server` package."""

import pytest


from log_aggregator_server import log_aggregator_server


@pytest.fixture
def reference_obj():
    return log_aggregator_server.Reference()


def test_content(reference_obj):
    assert reference_obj.greeting() == "Hello Yujin!"
