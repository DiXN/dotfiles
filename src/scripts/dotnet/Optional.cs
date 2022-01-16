using System;
using System.Collections.Generic;

public static class Optional
{
  public static Optional<T> Of<T>(T elem) => new Optional<T>(elem);

  public static Optional<T> Empty<T>() => new Optional<T>(default(T));
}

public struct Optional<T>
{
    public bool HasValue { get; private set; }

    private T value;
    public T Value
    {
        get
        {
            if (HasValue)
                return value;
            else
                throw new InvalidOperationException();
        }
    }

    public Optional(T value): this()
    {
        if (!EqualityComparer<T>.Default.Equals(value, default(T)))
        {
            this.value = value;
            HasValue = true;
        }
        else
        {
            HasValue = false;
        }
    }

    public static explicit operator T(Optional<T> optional) => optional.Value;

    public static implicit operator Optional<T>(T value) => new Optional<T>(value);

    public static bool operator ==(Optional<T> left, Optional<T> right) => left.Equals(right);

    public static bool operator !=(Optional<T> left, Optional<T> right) => !left.Equals(right);

    public override bool Equals(object obj)
    {
        if (obj is Optional<T>)
            return this.Equals((Optional<T>)obj);
        else
            return false;
    }

    public bool Equals(Optional<T> other)
    {
        if (HasValue && other.HasValue)
            return object.Equals(value, other.value);
        else
            return HasValue == other.HasValue;
    }

    public override int GetHashCode() => this.Value.GetHashCode() * 17 + this.HasValue.GetHashCode();

    public void IfPresent(Action<T> action)
    {
        if (HasValue)
            action(value);
    }

    public void IfPresentOrElse(Action<T> present, Action elseAction)
    {
        if (HasValue)
            present(value);
        else
            elseAction();
    }

    public T OrElse(T elem)
    {
        if (!HasValue)
            return elem;
        else
            return value;
    }

    public void OrElse(T elem, Action<T> action)
    {
        if (!HasValue)
            action(elem);
        else
            action(value);
    }
}
