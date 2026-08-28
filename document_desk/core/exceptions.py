"""
Domain-specific exception hierarchy.

Keeping exceptions typed and centralized allows the API layer to translate
them into consistent, well-documented HTTP responses instead of leaking
implementation details (stack traces, third-party errors) to clients.
"""

from __future__ import annotations


class DocumentDeskError(Exception):
    """Base class for all application-specific errors."""

    default_message = "An unexpected error occurred."

    def __init__(self, message: str | None = None) -> None:
        super().__init__(message or self.default_message)
        self.message = message or self.default_message


class DocumentNotFoundError(DocumentDeskError):
    default_message = "The requested document was not found."


class UnsupportedFileTypeError(DocumentDeskError):
    default_message = "Only PDF files are supported."


class FileTooLargeError(DocumentDeskError):
    default_message = "The uploaded file exceeds the maximum allowed size."


class EmptyDocumentError(DocumentDeskError):
    default_message = "No extractable text was found in the document."


class VectorStoreNotReadyError(DocumentDeskError):
    default_message = "The vector store has not been built yet. Upload a document first."


class ConversationNotFoundError(DocumentDeskError):
    default_message = "The requested conversation was not found."


class OpenAIServiceError(DocumentDeskError):
    default_message = "The AI service failed to generate a response."


class MissingAPIKeyError(DocumentDeskError):
    default_message = (
        "OPENAI_API_KEY is not configured. Add it to your .env file to use this feature."
    )
