"""Integration tests for document upload / listing / deletion endpoints.

These tests exercise the extraction and chunking pipeline end-to-end but do
NOT call the real OpenAI API (embeddings are network calls), so they are
skipped automatically unless a real ``OPENAI_API_KEY`` is present. This keeps
the test suite runnable offline / in CI without incurring API costs.
"""

from __future__ import annotations

import os
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from document_desk.main import app

client = TestClient(app)

requires_openai_key = pytest.mark.skipif(
    os.environ.get("OPENAI_API_KEY", "").startswith("sk-test"),
    reason="Requires a real OPENAI_API_KEY to generate embeddings.",
)


def test_list_documents_empty_by_default() -> None:
    response = client.get("/api/documents")
    assert response.status_code == 200
    assert "documents" in response.json()


def test_upload_rejects_non_pdf(tmp_path: Path) -> None:
    fake_file = tmp_path / "not-a-pdf.txt"
    fake_file.write_text("hello world")

    with fake_file.open("rb") as fh:
        response = client.post(
            "/api/documents", files={"file": ("not-a-pdf.txt", fh, "text/plain")}
        )

    assert response.status_code == 400


@requires_openai_key
def test_upload_indexes_sample_pdf(sample_pdf_path: Path) -> None:
    with sample_pdf_path.open("rb") as fh:
        response = client.post(
            "/api/documents", files={"file": (sample_pdf_path.name, fh, "application/pdf")}
        )

    assert response.status_code == 201
    body = response.json()
    assert body["document"]["status"] == "indexed"
    assert body["document"]["chunk_count"] > 0
